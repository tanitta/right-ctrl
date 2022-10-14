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
            int currentLayer = 0;

            Disposable[] disposableLayer0 = createDisposableLayer0;
            Disposable[] disposableLayer1;
            Disposable[] disposableLayer2;
            import std.algorithm;

            _currentPad.onDownButton(Button.Start)
                       .doSubscribe!((_){
                                             downKey(Key.Enter);
                                             upKey(Key.Enter);
                                        });

            _currentPad.onDownButton(Button.R1)
                       .doSubscribe!((_){
                                            if(currentLayer == 0){
                                                disposableLayer0.each!(d => d.dispose());
                                                disposableLayer1 = createDisposableLayer1();
                                                currentLayer = 1;
                                            }
                                        });
            _currentPad.onUpButton(Button.R1)
                       .doSubscribe!((_){
                                            disposableLayer1.each!(d => d.dispose());
                                            currentLayer = 0;
                                            disposableLayer0 = createDisposableLayer0();
                                        });

            _currentPad.onDownButton(Button.R2)
                       .doSubscribe!((_){
                                            if(currentLayer == 0){
                                                disposableLayer0.each!(d => d.dispose());
                                                disposableLayer2 = createDisposableLayer2();
                                                currentLayer = 2;
                                            }
                                        });
            _currentPad.onUpButton(Button.R2)
                       .doSubscribe!((_){
                                            disposableLayer2.each!(d => d.dispose());
                                            currentLayer = 0;
                                            disposableLayer0 = createDisposableLayer0();
                                        });
        }

        auto createDisposableLayer0(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe!((_){
                                          downKey(Key.Z, 0x00100000);
                                          upKey(Key.Z);
                                      });
            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                downKey(Key.Z, 0x00120000);
                                                upKey(Key.Z);
                                             });
            disposables ~=
            _currentPad.onStayButtonPeriodicly(Button.X)
                       .doSubscribe((bool b){
                                                downKey(Key.CloseBracket);
                                                upKey(Key.CloseBracket);
                                        });
            disposables ~=
            _currentPad.onStayButtonPeriodicly(Button.A)
                       .doSubscribe((bool b){
                                                downKey(Key.OpenBracket);
                                                upKey(Key.OpenBracket);
                                        });

            // toolselect
            disposables ~=
            _currentPad.onDownButton(Button.RightStick)
                       .doSubscribe((bool b){
                                                // downKey(Key.I);
                                                toggleDefaultTool();
                                            })
                       .withDisposed((){
                                        //    upKey(Key.I);
                                       });
            disposables ~=
            _currentPad.onUpButton(Button.RightStick)
                       .doSubscribe((bool b){
                                                // upKey(Key.I);
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                downKey(Key.R);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                upKey(Key.R);
                                                resetToolToDefault();
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RDown)
                       .doSubscribe((bool b){
                                                downKey(Key.Z);
                                        })
                       .withDisposed((){
                                           upKey(Key.Z);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RDown)
                       .doSubscribe((bool b){
                                                upKey(Key.Z);
                                                resetToolToDefault();
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                downKey(Key.I);
                                        })
                       .withDisposed((){
                                           upKey(Key.I);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                upKey(Key.I);
                                                resetToolToDefault();
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                downKey(Key.Space);
                                        })
                       .withDisposed((){
                                           upKey(Key.Space);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                upKey(Key.Space);
                                                resetToolToDefault();
                                        });

            return disposables;
        }

        auto createDisposableLayer1(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.X)
                       .doSubscribe((bool b){
                                                downKey(Key.C, 0x00100000);
                                                upKey(Key.C);
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.A)
                       .doSubscribe((bool b){
                                                downKey(Key.D, 0x00100000);
                                                upKey(Key.D);
                                            });

            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe((bool b){
                                                downKey(Key.T, 0x00100000);
                                                upKey(Key.T);
                                            })
                       .withDisposed((){
                                       });

            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                downKey(Key.V, 0x00100000);
                                                upKey(Key.V);
                                            })
                       .withDisposed((){
                                       });


            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                downKey(Key.L);
                                        })
                       .withDisposed((){
                                           upKey(Key.L);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                upKey(Key.W);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });
            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                downKey(Key.W);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                upKey(Key.W);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });


            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                downKey(Key.V);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                upKey(Key.V);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            return disposables;
        }

        auto createDisposableLayer2(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe((bool b){
                                                setDrawTool(Key.B);
                                                // downKey(Key.Tab); 
                                                // upKey(Key.Tab); 
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.X)
                       .doSubscribe((bool b){
                                                setDrawTool(Key.J);
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                setDrawTool(Key.P);
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.A)
                       .doSubscribe((bool b){
                                                setDrawTool(Key.G);
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.RightStick)
                       .doSubscribe((bool b){
                                                downKey(Key.Control); 
                                                downKey(Key.H); 
                                                upKey(Key.H); 
                                                upKey(Key.Control); 
                                            });
            return disposables;
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

        void setDrawTool(in Key key){
            _drawToolKey = key;
            Key prevKey = _defalutToolKey;
            _defalutToolKey = _drawToolKey;
            upKey(prevKey);
            downKey(_defalutToolKey);
            upKey(_defalutToolKey);
        }

        void toggleDefaultTool(){
            Key prevKey = _defalutToolKey;
            if(_defalutToolKey == _drawToolKey){
                _defalutToolKey = Key.E;
            }else{
                _defalutToolKey = _drawToolKey;
            }

            upKey(prevKey);
            downKey(_defalutToolKey);
            upKey(_defalutToolKey);
        }

        void resetToolToDefault(){
            downKey(_defalutToolKey);
            upKey(_defalutToolKey);
        }
    }//private
}//class RightCtrl
