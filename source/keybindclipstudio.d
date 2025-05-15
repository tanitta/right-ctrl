module keybindclipstudio;
import keybindable;
import gamepad;
import rx;
import keyutils;

class KeyBindClipStudio: KeyBindable{
    public string name(){
        return "ClipStudio";
    }

    Disposable[] _disposablesLayerSelect;
    Disposable[] _disposablesLayer0;
    Disposable[] _disposablesLayer1;
    Disposable[] _disposablesLayer2;
    int _currentLayer = 0;

    public Disposable[] disposables(){
        return _disposablesLayerSelect ~ _disposablesLayer0 ~ _disposablesLayer1 ~ _disposablesLayer2;

    }

    public void setup(SDLGamePad pad){
        _disposablesLayer0 = createDisposableLayer0(pad);
        _disposablesLayer1 = createDisposableLayer1(pad);
        _disposablesLayer2 = createDisposableLayer2(pad);
        import std.algorithm;

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.Start)
                    .doSubscribe!((_){
                                            downKey(Key.Enter);
                                            upKey(Key.Enter);
                                    });

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.R1)
                    .doSubscribe!((_){
                                        if(_currentLayer == 0){
                                            // _disposablesLayer0.each!(d => d.dispose());
                                            // _disposablesLayer0 = [];
                                            // _disposablesLayer1 = createDisposableLayer1(pad);
                                            _currentLayer = 1;
                                        }
                                    });

        _disposablesLayerSelect ~=
        pad.onUpButton(Button.R1)
                    .doSubscribe!((_){
                                        // _disposablesLayer1.each!(d => d.dispose());
                                        // _disposablesLayer1 = [];
                                        _currentLayer = 0;
                                        // _disposablesLayer0 = createDisposableLayer0(pad);
                                    });

        _disposablesLayerSelect ~=
        pad.onDownButton(Button.R2)
                    .doSubscribe!((_){
                                        if(_currentLayer == 0){
                                            // _disposablesLayer0.each!(d => d.dispose());
                                            // _disposablesLayer0 = [];
                                            // _disposablesLayer2 = createDisposableLayer2(pad);
                                            _currentLayer = 2;
                                        }
                                    });

        _disposablesLayerSelect ~=
        pad.onUpButton(Button.R2)
                    .doSubscribe!((_){
                                        // _disposablesLayer2.each!(d => d.dispose());
                                        // _disposablesLayer2 = [];
                                        _currentLayer = 0;
                                        // _disposablesLayer0 = createDisposableLayer0(pad);
                                    });
    }

    auto filterWithLayere(O)(O observable, int layer){
        return observable.filter!(v=>_currentLayer == layer);
    }

    // auto onUpButtonLayered(Button b, Layer layer){

    // }

    // auto onStayButtonPeriodiclyLayered(AxisButton b, Layer layer){}
    // auto onStayButtonPeriodiclyLayered(AxisButton b, Layer layer){}



    auto createDisposableLayer0(SDLGamePad pad){
        Disposable[] disposables;
        int layer = 0;
        disposables ~=
        pad.onDownButton(Button.Y).filter!(v=>_currentLayer == layer)
                                  .doSubscribe!((_){
                                      downKey(Key.Z, 0x00100000);
                                      upKey(Key.Z);
                                  });
        disposables ~=
        pad.onDownButton(Button.B).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.Z, 0x00120000);
                                            upKey(Key.Z);
                                            });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.X).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.CloseBracket);
                                            upKey(Key.CloseBracket);
                                    });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.A).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.OpenBracket);
                                            upKey(Key.OpenBracket);
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
                                            downKey(Key.R);
                                    })
                    .withDisposed((){
                                        upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.R);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RDown).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.Z);
                                    })
                    .withDisposed((){
                                        upKey(Key.Z);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RDown).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.Z);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.I);
                                    })
                    .withDisposed((){
                                        upKey(Key.I);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.I);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.Space);
                                    })
                    .withDisposed((){
                                        upKey(Key.Space);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.Space);
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
                                            downKey(Key.C, 0x00100000);
                                            upKey(Key.C);
                                        });
        disposables ~=
        pad.onDownButton(Button.A).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.D, 0x00100000);
                                            upKey(Key.D);
                                        });

        disposables ~=
        pad.onDownButton(Button.Y).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.T, 0x00100000);
                                            upKey(Key.T);
                                        })
                    .withDisposed((){
                                    });

        disposables ~=
        pad.onDownButton(Button.B).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.V, 0x00100000);
                                            upKey(Key.V);
                                        })
                    .withDisposed((){
                                    });


        disposables ~=
        pad.onDownButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.L);
                                    })
                    .withDisposed((){
                                        upKey(Key.L);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RUp).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.L);
                                            resetToolToDefault();
                                    });
        disposables ~=
        pad.onDownButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.W);
                                    })
                    .withDisposed((){
                                        upKey(Key.W);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RLeft).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.W);
                                            resetToolToDefault();
                                    });


        disposables ~=
        pad.onDownButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            downKey(Key.V);
                                    })
                    .withDisposed((){
                                        // upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpButton(AxisButton.RRight).filter!(v=>_currentLayer == layer)
                    .doSubscribe((bool b){
                                            upKey(Key.V);
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
                                            downKey(Key.Control); 
                                            downKey(Key.H); 
                                            upKey(Key.H); 
                                            upKey(Key.Control); 
                                        });
        return disposables;
    }

    Key _defalutToolKey = Key.B;
    Key _drawToolKey;
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
}
