import std.stdio;
import core.thread;
import std.datetime;
import std.range;
import std.conv;
import derelict.sdl2.sdl;
import rx;
import std.container;
import gamepad;
import looprunner;
import std.exception;
import keybindable;
import keyutils;


// extern(C) void CFRelease(int*);



void main() {
    DerelictSDL2.load();
    SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS, "1");
    SDL_Init(0);scope(exit)SDL_Quit();
    SDL_InitSubSystem(SDL_INIT_JOYSTICK);

    auto ctrl = new RightCtrl();
    ctrl.searchPad;
    ctrl.setup();
    auto runner = (new LoopRunner()).targetFps(60f)
                                    .run((){ctrl.update();});
}

///
class RightCtrl{
    public{
        SDLGamePad currentPad(){
            return _currentPad;
        }

        void setup(){
            import keybindclipstudio;
            _bindables ~= new KeyBindClipStudio();
            // import keybindrebelle;
            // _bindables ~= new KeyBindRebelle();
            setupSelectionKeyBind();
            return;
        }

        void setupSelectionKeyBind(){
            import std.algorithm;
            int currentKeyBindIndex;
            KeyBindable currentKeyBind;
            currentKeyBind = _bindables[0];
            currentKeyBind.setup(_currentPad);
            writeln("Set Keybind: ", _bindables[0].name);
            currentPad.onDownButton(Button.Select)
                    .doSubscribe!((_){
                                          currentKeyBind.disposables.each!(d => d.dispose());
                                          currentKeyBindIndex++;
                                          if(_bindables.length<=currentKeyBindIndex){
                                              currentKeyBindIndex = 0;
                                          }
                                          currentKeyBind = _bindables[currentKeyBindIndex];
                                          currentKeyBind.setup(currentPad);
                                          writeln("Set Keybind: ", currentKeyBind.name);
                                    });
        }

        void searchPad(){
            import std.algorithm;
            detectAllGamePads();

            Disposable[] disposables;
            bool[] states;
            foreach(pad; _gamepads){
                uint index = _gamepads.countUntil(pad).to!uint;
                states ~= false;
                pad.setupGamePad;
                disposables ~= pad.onUpdateButton(Button.Start).doSubscribe!(value => states[index] = value);
            }

            bool isDetected = false;
            uint detectedPadIndex = 0;
            do{
                SDL_JoystickUpdate();
                foreach(i, pad; _gamepads){
                    _gamepads[i].update;
                    isDetected = states.canFind(true);
                    detectedPadIndex = i.to!uint;
                    if(isDetected)break;
                }
                import std.algorithm.iteration: stdFold = fold;
                Thread.sleep( dur!("msecs")(100));
            }while(!isDetected);

            foreach(disposable; disposables){
                disposable.dispose();
            }

            writeln("Detected! : ", detectedPadIndex);
            _currentPad = _gamepads[detectedPadIndex];
        }

        void update(){
            if(!_currentPad) return;
            SDL_JoystickUpdate();
            _currentPad.update;
        }
    }//public

    private{
        SDLGamePad _currentPad;
        SDLGamePad[] _gamepads;
        Key _defalutToolKey = Key.B;
        Key _drawToolKey;
        KeyBindable[] _bindables;
        int _currentKeyBindIndex;

        void detectAllGamePads(){
            foreach(joystickIndex; SDL_NumJoysticks().iota){
                auto handle = SDL_JoystickOpen(joystickIndex);
                if(!handle)continue;
                auto pad = new SDLGamePad(handle);
                pad.name.writeln;
                if(pad.isAttached) {
                    SDL_JoystickGetDeviceGUID(joystickIndex).writeln;
                    SDL_JoystickGetAttached(handle).writeln;
                    SDL_JoystickInstanceID(handle).writeln;
                    SDL_GetError.to!string.writeln;
                    _gamepads ~= pad;
                }
            }

            _gamepads.length.writeln;
            SDL_GetError().to!string.writeln;
        }
    }//private
}//class RightCtrl
