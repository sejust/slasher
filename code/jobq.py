#!/usr/bin/env python2.6
# coding: utf-8

import threading
import time
import Queue
import types


class EmptyRst( object ): pass
class Finish( object ): pass

def run( input_it, workers, keep_order=False, timeout=None, probe=None ):

    endtime = time.time() + ( timeout or 86400 * 102400 )
    if probe is None:
        probe = {}
    sessions = []
    probe[ 'sessions' ] = sessions
    head_q = _make_q()
    inq = head_q

    for worker in workers + [ _blackhole ]:

        if callable( worker ):
            worker = ( worker, 1 )

        worker, n = worker

        sess = { 'worker': worker,
                 'threads': [],
                 'input': inq, }

        outq = _make_q()

        if keep_order and n > 1:
            # to maximize concurrency
            sess[ 'queue_of_outq' ] = _make_q(n=1024*1024)
            sess[ 'lock' ] = threading.RLock()
            sess[ 'coor_th' ] = _thread( _coordinate, ( sess, outq ) )

            sess[ 'threads' ] = [ _thread( _exec_in_order, ( sess, _make_q() ) )
                                  for ii in range( n ) ]
        else:
            sess[ 'threads' ] = [ _thread( _exec, ( sess, outq ) )
                                  for ii in range( n ) ]

        sessions.append( sess )
        inq = outq

    for args in input_it:
        head_q.put( args )

    for sess in sessions:

        # put nr = len(threads) Finish
        for th in sess[ 'threads' ]:
            sess[ 'input' ].put( Finish )

        for th in sess[ 'threads' ]:
            th.join( endtime - time.time() )

        if 'queue_of_outq' in sess:
            sess[ 'queue_of_outq' ].put( Finish )
            sess[ 'coor_th' ].join( endtime - time.time() )

def stat( probe ):

    rst = []
    for sess in probe[ 'sessions' ]:
        o = {}
        wk = sess[ 'worker' ]
        o[ 'name' ] = wk.__module__ + ":" + wk.__name__

        o[ 'input' ] = _q_stat( sess[ 'input' ] )
        if 'queue_of_outq' in sess:
            o[ 'coordinator' ] = _q_stat( sess[ 'queue_of_outq' ] )

        rst.append( o )

    return rst


def _q_stat( q ):
    return { 'size': q.qsize(),
             'capa': q.maxsize
    }

def _exec( sess, output_q ):

    while True:

        args = sess[ 'input' ].get()
        if args is Finish:
            return

        try:
            rst = sess[ 'worker' ]( args )
        except Exception as e:
            continue

        _put_rst( output_q, rst )

def _exec_in_order( sess, output_q ):

    while True:

        with sess[ 'lock' ]:

            args = sess[ 'input' ].get()
            if args is Finish:
                return
            sess[ 'queue_of_outq' ].put( output_q )

        try:
            rst = sess[ 'worker' ]( args )

        except Exception as e:
            output_q.put( EmptyRst )
            continue

        output_q.put( rst )

def _coordinate( sess, output_q ):

    while True:

        outq = sess[ 'queue_of_outq' ].get()
        if outq is Finish:
            return

        _put_rst( output_q, outq.get() )

def _put_rst( output_q, rst ):

    if type( rst ) == types.GeneratorType:
        for rr in rst:
            _put_non_empty( output_q, rr )
    else:
        _put_non_empty( output_q, rst )

def _blackhole( args ):
    return EmptyRst

def _put_non_empty( q, val ):
    if val is not EmptyRst:
        q.put( val )

def _make_q( n=1024 ):
    return Queue.Queue( n )

def _thread( func, args ):
    th = threading.Thread( target=func,
                           args=args )
    th.daemon = True
    th.start()

    return th

if __name__ == "__main__":

    # Process serial of input elements with several functions concurrently and
    # sequentially

    def add1( args ):
        return args + 1

    def multi2( args ):
        return args * 2

    def printarg( args ):
        print args

    run( [ 0, 1, 2 ], [ add1, printarg ] )
    # > 1
    # > 2
    # > 3

    run( ( 0, 1, 2 ), [ add1, multi2, printarg ] )
    # > 2
    # > 4
    # > 6

    # Specify number of threads for each job:

    # Job 'multi2' uses 1 thread.
    # This is the same as the above example.
    run( range( 3 ), [ add1, (multi2, 1), printarg ] )
    # > 2
    # > 4
    # > 6

    # Create 2 threads for job 'multi2':

    # As there are 2 thread dealing with multi2, output order will not be kept.
    run( range( 3 ), [ add1, (multi2, 2), printarg ] )
    # Output could be:
    # > 4
    # > 2
    # > 6

    # Multiple threads with order kept:

    # keep_order=True to force to keep order even with concurrently running.
    run( range( 3 ), [ add1, (multi2, 2), printarg ],
              keep_order=True )
    # > 2
    # > 4
    # > 6

    # timeout=0.5 specifies that it runs at most 0.5 second.
    run( range( 3 ), [ add1, (multi2, 2), printarg ],
              timeout=0.5 )

    # Returning *jobq.EmptyRst* stops delivering result to next job:

    def drop_even_number( i ):
        if i % 2 == 0:
            return EmptyRst
        else:
            return i

    run( range( 10 ), [ drop_even_number, printarg ] )
    # > 1
    # > 3
    # > 5
    # > 7
    # > 9
