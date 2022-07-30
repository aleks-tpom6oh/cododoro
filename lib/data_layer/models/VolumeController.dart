final volumeController = _VolumeModel();

class _VolumeModel {
  bool _isSoundOn = true;

  bool get isSoundOn {
    return _isSoundOn;
  }

  set isSoundOn(isSoundOn) {
    _isSoundOn = isSoundOn;
  }
}
