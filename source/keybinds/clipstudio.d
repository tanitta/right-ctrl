module keybinds.clipstudio;
import keybindable;
import gamepad;
import rx;
import keyutils;
import std.stdio;
import keyboard;

class ClipStudio: KeyBindable{
    public string name(){
        return "ClipStudio";
    }

    Disposable[] _disposablesLayerSelect;
    Disposable[] _disposablesLayer0;
    Disposable[] _disposablesLayer1;
    Disposable[] _disposablesLayer2;
    int _currentLayer = 0;
    Keyboard _keyboard;

    public Disposable[] disposables(){
        return _disposablesLayerSelect ~ _disposablesLayer0 ~ _disposablesLayer1 ~ _disposablesLayer2;
    }

    public void setup(SDLGamePad pad, Keyboard keyboard){
        _keyboard = keyboard;
        _disposablesLayer0 = createDisposableLayer0(pad);
        _disposablesLayer1 = createDisposableLayer1(pad);
        _disposablesLayer2 = createDisposableLayer2(pad);
        import std.algorithm;

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.Start)
                    .doSubscribe!((_){
                                            _keyboard.downKey(Key.Enter);
                                            _keyboard.upKey(Key.Enter);
                                    });

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.R1)
                    .doSubscribe!((_){
                                        if(_currentLayer == 0){
                                            _currentLayer = 1;
                                        }
                                    });

        _disposablesLayerSelect ~=
        pad.onUpButton(Button.R1)
                    .doSubscribe!((_){
                                        _currentLayer = 0;
                                        // TODO: Reset Keydown
                                        _keyboard.reset();
                                    });

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.R2)
                    .doSubscribe!((_){
                                        if(_currentLayer == 0){
                                            _currentLayer = 2;
                                        }
                                    });

        _disposablesLayerSelect ~=
        pad.onUpButton(Button.R2)
                    .doSubscribe!((_){
                                        _currentLayer = 0;
                                        // TODO: Reset Keydown
                                        _keyboard.reset();
                                    });
    }

    auto filterWithLayere(O)(O observable, int layer){
        return observable.filter!(v=>_currentLayer == layer);
    }

    auto createDisposableLayer0(SDLGamePad pad){
        Disposable[] disposables;
        int layer = 0;
        disposables ~=
        pad.onDownButton(Button.Y).filter!(v=>_currentLayer == layer)
                                  .doSubscribe!((_){
                                      _keyboard.downKey(Key.Z, 0x00100000);
                                      _keyboard.upKey(Key.Z);
                                  });
        disposables ~=
        pad.onDownButton(Button.B).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.Z, 0x00120000);
                                            _keyboard.upKey(Key.Z);
                                            });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.X).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.CloseBracket);
                                            _keyboard.upKey(Key.CloseBracket);
                                    });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.A).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.OpenBracket);
                                            _keyboard.upKey(Key.OpenBracket);
                                    });

        // toolselect
        disposables ~=
        pad.onDownButton(Button.RightStick).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            // downKey(Key.I);
                                            toggleDefaultTool();
                                        })
                    .withDisposed((){
                                    //    upKey(Key.I);
                                    });
        disposables ~=
        pad.onUpButton(Button.RightStick).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            // upKey(Key.I);
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.R);
                                    })
                    .withDisposed((){
                                        _keyboard.upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.R);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RDown).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.Z);
                                    })
                    .withDisposed((){
                                        _keyboard.upKey(Key.Z);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RDown).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.Z);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.I);
                                    })
                    .withDisposed((){
                                        _keyboard.upKey(Key.I);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.I);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.Space);
                                    })
                    .withDisposed((){
                                        _keyboard.upKey(Key.Space);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.Space);
                                            resetToolToDefault();
                                    });

        return disposables;
    }

    auto createDisposableLayer1(SDLGamePad pad){
        Disposable[] disposables;
        int layer = 1;
        disposables ~=
        pad.onDownButton(Button.X).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.C, 0x00100000);
                                            _keyboard.upKey(Key.C);
                                        });
        disposables ~=
        pad.onDownButton(Button.A).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.D, 0x00100000);
                                            _keyboard.upKey(Key.D);
                                        });

        disposables ~=
        pad.onDownButton(Button.Y).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.T, 0x00100000);
                                            _keyboard.upKey(Key.T);
                                        })
                    .withDisposed((){
                                    });

        disposables ~=
        pad.onDownButton(Button.B).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.V, 0x00100000);
                                            _keyboard.upKey(Key.V);
                                        })
                    .withDisposed((){
                                    });


        disposables ~=
        pad.onDownButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.L);
                                    })
                    .withDisposed((){
                                        writeln("Dispose Up");
                                        _keyboard.upKey(Key.L);
                                        resetToolToDefault();
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                        writeln("Dispose Up(doSubscribe)");
                                        _keyboard.upKey(Key.L);
                                        resetToolToDefault();
                                    });
        disposables ~=
        pad.onDownButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.W);
                                    })
                    .withDisposed((){
                                        _keyboard.upKey(Key.W);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.W);
                                            resetToolToDefault();
                                    });


        disposables ~=
        pad.onDownButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.V);
                                    })
                    .withDisposed((){
                                        // upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.upKey(Key.V);
                                            resetToolToDefault();
                                    });

        return disposables;
    }

    auto createDisposableLayer2(SDLGamePad pad){
        Disposable[] disposables;
        int layer = 2;
        disposables ~=
        pad.onDownButton(Button.Y).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.B);
                                            // downKey(Key.Tab); 
                                            // upKey(Key.Tab); 
                                        });
        disposables ~=
        pad.onDownButton(Button.X).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.J);
                                        });
        disposables ~=
        pad.onDownButton(Button.B).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.P);
                                        });
        disposables ~=
        pad.onDownButton(Button.A).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.G);
                                        });
        disposables ~=
        pad.onDownButton(Button.RightStick).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            _keyboard.downKey(Key.Control); 
                                            _keyboard.downKey(Key.H); 
                                            _keyboard.upKey(Key.H); 
                                            _keyboard.upKey(Key.Control); 
                                        });
        return disposables;
    }

    Key _defalutToolKey = Key.B;
    Key _drawToolKey;
    void setDrawTool(in Key key){
        _drawToolKey = key;
        Key prevKey = _defalutToolKey;
        _defalutToolKey = _drawToolKey;
        _keyboard.upKey(prevKey);
        _keyboard.downKey(_defalutToolKey);
        _keyboard.upKey(_defalutToolKey);
    }

    void toggleDefaultTool(){
        Key prevKey = _defalutToolKey;
        if(_defalutToolKey == _drawToolKey){
            _defalutToolKey = Key.E;
        }else{
            _defalutToolKey = _drawToolKey;
        }

        _keyboard.upKey(prevKey);
        _keyboard.downKey(_defalutToolKey);
        _keyboard.upKey(_defalutToolKey);
    }

    void resetToolToDefault(){
        _keyboard.downKey(_defalutToolKey);
        _keyboard.upKey(_defalutToolKey);
    }
}
