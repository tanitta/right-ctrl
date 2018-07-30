module looprunner;
import std.datetime;
import core.thread;
import std.conv;
///
class LoopRunner {
    public{
        this(){
            _targetFps = 60f;
            _currentFps = 60f;
            // _timer = MonoTime.currTime;
        }

        float targetFps(){
            return _targetFps;
        }

        float currentFps(){
            return _currentFps;
        }

        LoopRunner targetFps(float fps){
            _targetFps = fps;
            return this;
        }

        LoopRunner run(void delegate() f){
            bool shouldExit = false;
            do {
                beginTimeCounting();
                f();
                auto diff = endTimeCounting();
                adjustTimeIfNeeded(diff);
            } while (!shouldExit);
            return this;
        }

    }//public

    private{
        float _targetFps;
        float _currentFps;
        MonoTime _timer;

        void adjustTimeIfNeeded(in long time){
            auto targetNsecsTime = (1.0/_targetFps*1000000000.0).to!int;
            if( time< targetNsecsTime){
                Thread.sleep( dur!("nsecs")( targetNsecsTime - time) );
            }
        }

        void beginTimeCounting(){
            _timer = MonoTime.currTime;
        }

        long endTimeCounting(){
            immutable MonoTime after = MonoTime.currTime;
            immutable diff = ( after.ticks - _timer.ticks ).ticksToNSecs;
            _currentFps = 1.0/diff.to!double*1000000000.0;
            return diff;
        }
    }//private
}//class LoopRunner
