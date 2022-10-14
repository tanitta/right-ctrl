module keybindclipstudio;
import keybindable;
import gamepad;
import rx;
import keyutils;

class KeyBindClipStudio: KeyBindable{
    public string name(){
        return "ClipStudio";
    }

    public Disposable[] setup(SDLGamePad pad){
        Disposable[] disposables;
        int currentLayer = 0;

        Disposable[] disposableLayer0 = createDisposableLayer0(pad);
        Disposable[] disposableLayer1;
        Disposable[] disposableLayer2;
        import std.algorithm;

        disposables ~=
        pad.onDownButton(Button.Start)
                    .doSubscribe!((_){
                                            downKey(Key.Enter);
                                            upKey(Key.Enter);
                                    });

        disposables ~=
        pad.onDownButton(Button.R1)
                    .doSubscribe!((_){
                                        if(currentLayer == 0){
                                            disposableLayer0.each!(d => d.dispose());
                                            disposableLayer1 = createDisposableLayer1(pad);
                                            currentLayer = 1;
                                        }
                                    });

        disposables ~=
        pad.onUpButton(Button.R1)
                    .doSubscribe!((_){
                                        disposableLayer1.each!(d => d.dispose());
                                        currentLayer = 0;
                                        disposableLayer0 = createDisposableLayer0(pad);
                                    });

        disposables ~=
        pad.onDownButton(Button.R2)
                    .doSubscribe!((_){
                                        if(currentLayer == 0){
                                            disposableLayer0.each!(d => d.dispose());
                                            disposableLayer2 = createDisposableLayer2(pad);
                                            currentLayer = 2;
                                        }
                                    });

        disposables ~=
        pad.onUpButton(Button.R2)
                    .doSubscribe!((_){
                                        disposableLayer2.each!(d => d.dispose());
                                        currentLayer = 0;
                                        disposableLayer0 = createDisposableLayer0(pad);
                                    });
        return disposables;
    }

    auto createDisposableLayer0(SDLGamePad pad){
        Disposable[] disposables;
        disposables ~=
        pad.onDownButton(Button.Y)
                    .doSubscribe!((_){
                                        downKey(Key.Z, 0x00100000);
                                        upKey(Key.Z);
                                    });
        disposables ~=
        pad.onDownButton(Button.B)
                    .doSubscribe((bool b){
                                            downKey(Key.Z, 0x00120000);
                                            upKey(Key.Z);
                                            });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.X)
                    .doSubscribe((bool b){
                                            downKey(Key.CloseBracket);
                                            upKey(Key.CloseBracket);
                                    });
        disposables ~=
        pad.onStayButtonPeriodicly(Button.A)
                    .doSubscribe((bool b){
                                            downKey(Key.OpenBracket);
                                            upKey(Key.OpenBracket);
                                    });

        // toolselect
        disposables ~=
        pad.onDownButton(Button.RightStick)
                    .doSubscribe((bool b){
                                            // downKey(Key.I);
                                            toggleDefaultTool();
                                        })
                    .withDisposed((){
                                    //    upKey(Key.I);
                                    });
        disposables ~=
        pad.onUpButton(Button.RightStick)
                    .doSubscribe((bool b){
                                            // upKey(Key.I);
                                    });

        disposables ~=
        pad.onDownAxisButton(AxisButton.RLeft)
                    .doSubscribe((bool b){
                                            downKey(Key.R);
                                    })
                    .withDisposed((){
                                        upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RLeft)
                    .doSubscribe((bool b){
                                            upKey(Key.R);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownAxisButton(AxisButton.RDown)
                    .doSubscribe((bool b){
                                            downKey(Key.Z);
                                    })
                    .withDisposed((){
                                        upKey(Key.Z);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RDown)
                    .doSubscribe((bool b){
                                            upKey(Key.Z);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownAxisButton(AxisButton.RUp)
                    .doSubscribe((bool b){
                                            downKey(Key.I);
                                    })
                    .withDisposed((){
                                        upKey(Key.I);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RUp)
                    .doSubscribe((bool b){
                                            upKey(Key.I);
                                            resetToolToDefault();
                                    });

        disposables ~=
        pad.onDownAxisButton(AxisButton.RRight)
                    .doSubscribe((bool b){
                                            downKey(Key.Space);
                                    })
                    .withDisposed((){
                                        upKey(Key.Space);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RRight)
                    .doSubscribe((bool b){
                                            upKey(Key.Space);
                                            resetToolToDefault();
                                    });

        return disposables;
    }

    auto createDisposableLayer1(SDLGamePad pad){
        Disposable[] disposables;
        disposables ~=
        pad.onDownButton(Button.X)
                    .doSubscribe((bool b){
                                            downKey(Key.C, 0x00100000);
                                            upKey(Key.C);
                                        });
        disposables ~=
        pad.onDownButton(Button.A)
                    .doSubscribe((bool b){
                                            downKey(Key.D, 0x00100000);
                                            upKey(Key.D);
                                        });

        disposables ~=
        pad.onDownButton(Button.Y)
                    .doSubscribe((bool b){
                                            downKey(Key.T, 0x00100000);
                                            upKey(Key.T);
                                        })
                    .withDisposed((){
                                    });

        disposables ~=
        pad.onDownButton(Button.B)
                    .doSubscribe((bool b){
                                            downKey(Key.V, 0x00100000);
                                            upKey(Key.V);
                                        })
                    .withDisposed((){
                                    });


        disposables ~=
        pad.onDownAxisButton(AxisButton.RUp)
                    .doSubscribe((bool b){
                                            downKey(Key.L);
                                    })
                    .withDisposed((){
                                        upKey(Key.L);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RUp)
                    .doSubscribe((bool b){
                                            upKey(Key.W);
                                            downKey(Key.B);
                                            upKey(Key.B);
                                    });
        disposables ~=
        pad.onDownAxisButton(AxisButton.RLeft)
                    .doSubscribe((bool b){
                                            downKey(Key.W);
                                    })
                    .withDisposed((){
                                        upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RLeft)
                    .doSubscribe((bool b){
                                            upKey(Key.W);
                                            downKey(Key.B);
                                            upKey(Key.B);
                                    });


        disposables ~=
        pad.onDownAxisButton(AxisButton.RRight)
                    .doSubscribe((bool b){
                                            downKey(Key.V);
                                    })
                    .withDisposed((){
                                        upKey(Key.R);
                                    });
        disposables ~=
        pad.onUpAxisButton(AxisButton.RRight)
                    .doSubscribe((bool b){
                                            upKey(Key.V);
                                            downKey(Key.B);
                                            upKey(Key.B);
                                    });

        return disposables;
    }

    auto createDisposableLayer2(SDLGamePad pad){
        Disposable[] disposables;
        disposables ~=
        pad.onDownButton(Button.Y)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.B);
                                            // downKey(Key.Tab); 
                                            // upKey(Key.Tab); 
                                        });
        disposables ~=
        pad.onDownButton(Button.X)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.J);
                                        });
        disposables ~=
        pad.onDownButton(Button.B)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.P);
                                        });
        disposables ~=
        pad.onDownButton(Button.A)
                    .doSubscribe((bool b){
                                            setDrawTool(Key.G);
                                        });
        disposables ~=
        pad.onDownButton(Button.RightStick)
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
