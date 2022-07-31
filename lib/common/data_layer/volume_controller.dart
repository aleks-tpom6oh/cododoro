final volumeController = _VolumeController();

class _VolumeController {
  bool _isSoundOn = true;

  bool get isSoundOn {
    return _isSoundOn;
  }

  set isSoundOn(isSoundOn) {
    _isSoundOn = isSoundOn;
  }
}
