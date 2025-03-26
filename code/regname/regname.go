package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"runtime/debug"
	"sort"
	"strings"

	"golang.org/x/text/width"
)

const tmplOrder = "${o}"

type sortedEntry []os.DirEntry

func (e sortedEntry) Len() int           { return len(e) }
func (e sortedEntry) Swap(i, j int)      { e[i], e[j] = e[j], e[i] }
func (e sortedEntry) Less(i, j int) bool { return e[i].Name() < e[j].Name() }
func (e sortedEntry) MaxLength() (maxlen int) {
	for _, entry := range e {
		if l := strWidth(entry.Name()); l > maxlen {
			maxlen = l
		}
	}
	return
}

func strWidth(s string) (w int) {
	for _, r := range s {
		switch width.LookupRune(r).Kind() {
		case width.EastAsianFullwidth, width.EastAsianWide:
			w += 2
		default:
			w += 1
		}
	}
	return
}

func walk(mode int, dir, expr, template string, dryrun bool) error {
	absdir, err := filepath.Abs(dir)
	if err != nil {
		return err
	}
	fmt.Println("Walk directory:", absdir)
	if mode == 3 {
		return secondary(absdir, expr, template, dryrun)
	}

	_entries, err := os.ReadDir(absdir)
	if err != nil {
		return err
	}
	entries := sortedEntry(_entries)
	sort.Sort(entries)

	step := "Test"
	if !dryrun {
		step = "Done"
	}

	maxlen := entries.MaxLength()
	number := 1
	for _, entry := range entries {
		oldname := entry.Name()
		pad := maxlen - strWidth(oldname)
		format := fmt.Sprintf("[%s] %%s%s -> %%s\n", step, strings.Repeat(" ", pad))

		if mode == 1 && !entry.IsDir() {
			fmt.Printf(format, oldname, "Skip file")
			continue
		}
		if (mode == 2 || *copied) && entry.IsDir() {
			fmt.Printf(format, oldname, "Skip directory")
			continue
		}

		name := oldname
		var ext string
		if !*extension && !entry.IsDir() {
			if idx := strings.LastIndexByte(oldname, '.'); idx > 0 {
				name, ext = oldname[:idx], oldname[idx:]
			}
		}

		tmpl := template
		if *order > 0 {
			orderstr := fmt.Sprintf(fmt.Sprintf("%%0%dd", *order), number)
			if strings.Contains(tmpl, tmplOrder) {
				tmpl = strings.Replace(tmpl, tmplOrder, orderstr, -1)
			} else {
				tmpl += orderstr
			}
		}
		newname := regexp.MustCompile(expr).ReplaceAllString(name, tmpl)
		if name == newname {
			fmt.Printf(format, oldname, "Skip same name")
			continue
		}

		newname += ext
		fmt.Printf(format, oldname, newname)
		number++
		if dryrun {
			continue
		}

		oldname = filepath.Join(absdir, oldname)
		newname = filepath.Join(absdir, newname)
		if *copied {
			err = os.Link(oldname, newname)
		} else {
			err = os.Rename(oldname, newname)
		}
		if err != nil {
			return err
		}
	}

	return nil
}

func secondary(absdir, expr, template string, dryrun bool) error {
	dirs, err := os.ReadDir(absdir)
	if err != nil {
		return err
	}
	step := "Test"
	if !dryrun {
		step = "Done"
	}

	maxlen := 0
	for _, dirEntry := range dirs {
		if !dirEntry.IsDir() {
			continue
		}
		_entries, err := os.ReadDir(filepath.Join(absdir, dirEntry.Name()))
		if err != nil {
			return err
		}
		entries := sortedEntry(_entries)
		if l := strWidth(dirEntry.Name()) + 1 + entries.MaxLength(); l > maxlen {
			maxlen = l
		}
	}

	for _, dirEntry := range dirs {
		if !dirEntry.IsDir() {
			continue
		}

		_entries, err := os.ReadDir(filepath.Join(absdir, dirEntry.Name()))
		if err != nil {
			return err
		}
		entries := sortedEntry(_entries)
		sort.Sort(entries)

		number := 1
		for _, entry := range entries {
			oldname := entry.Name()
			pad := maxlen - strWidth(dirEntry.Name()+oldname) - 1
			format := fmt.Sprintf("[%s] %%s%%s -> %%s\n", step)

			if len(entries) >= *skip {
				fmt.Printf(format, dirEntry.Name(),
					strings.Repeat(" ", maxlen-strWidth(dirEntry.Name())),
					"Skip secondary many files")
				break
			}
			if entry.IsDir() {
				fmt.Printf(format, filepath.Join(dirEntry.Name(), oldname),
					strings.Repeat(" ", pad),
					"Skip secondary directory")
				continue
			}

			name := oldname
			var ext string
			if !*extension {
				if idx := strings.LastIndexByte(oldname, '.'); idx > 0 {
					name, ext = oldname[:idx], oldname[idx:]
				}
			}

			tmpl := template
			if *order > 0 {
				orderstr := fmt.Sprintf(fmt.Sprintf("%%0%dd", *order), number)
				if strings.Contains(tmpl, tmplOrder) {
					tmpl = strings.Replace(tmpl, tmplOrder, orderstr, -1)
				} else {
					tmpl += orderstr
				}
			}
			newname := regexp.MustCompile(expr).ReplaceAllString(name, tmpl)
			newname += ext

			oldname = filepath.Join(dirEntry.Name(), oldname)
			newname = dirEntry.Name() + newname
			fmt.Printf(format, oldname, strings.Repeat(" ", pad), newname)
			number++
			if dryrun {
				continue
			}

			oldname = filepath.Join(absdir, oldname)
			newname = filepath.Join(absdir, newname)
			if *copied {
				err = os.Link(oldname, newname)
			} else {
				err = os.Rename(oldname, newname)
			}
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func confirm(s string, anykey bool) bool {
	for {
		fmt.Printf("%s [Y / N]: ", s)

		var response string
		if _, err := fmt.Scanln(&response); err != nil {
			return false
		}

		response = strings.ToLower(strings.TrimSpace(response))
		switch response {
		case "y", "yes":
			return true
		case "n", "no":
			return false
		default:
			if anykey {
				return false
			}
		}
	}
}

var (
	mode = flag.Int("mode", 0, "(0) File & Directory in local directory\n"+
		"(1) Directory in local directory\n"+
		"(2) File in local directory\n"+
		"(3) Rename File in secondary directory to local directory")
	dir      = flag.String("dir", ".", "Directory to walk")
	expr     = flag.String("expr", "^(.*)$", "Regular expression to extract name")
	template = flag.String("template", "${1}", "Rename to template")
	order    = flag.Int("order", 0,
		fmt.Sprintf("Order, %s is place in template\n", tmplOrder)+
			"Default order is like ${template}${order}${extension}")
	extension = flag.Bool("extension", false, "Match with file extension")
	copied    = flag.Bool("copy", false, "Copy file instead rename")
	skip      = flag.Int("skip", 10, "Skip too many files directory if mode=3")
)

func main() {
	defer confirm("Press any key to quit", true)
	defer func() {
		if p := recover(); p != nil {
			fmt.Println(p)
			fmt.Println(string(debug.Stack()))
		}
	}()

	flag.Parse()

	if err := walk(*mode, *dir, *expr, *template, true); err != nil {
		panic(err)
	}
	if confirm("Run All?", false) {
		if err := walk(*mode, *dir, *expr, *template, false); err != nil {
			panic(err)
		}
	}
}
