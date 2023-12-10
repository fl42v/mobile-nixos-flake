self: super: {
  libqmi = (super.libqmi.overrideAttrs {_:
    version = "1.34.0";
  });

  iio-sensor-proxy = super.iio-sensor-proxy.overrideAttrs {_: 
    # https://gitlab.com/dylanvanassche/pmaports/-/tree/qcom-sdm845-sensors/temp/iio-sensor-proxy
    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "hadess";
      repo = "iio-sensor-proxy";
      rev = "48cb957c41b8d51d882219866e1366c45e21c352";
      hash = "";
    };
    patches = [
      ./patches/0001-iio-sensor-proxy-depend-on-libssc.patch
      ./patches/0002-proximity-support-SSC-proximity-sensor.patch
      ./patches/0003-light-support-SSC-light-sensor.patch
      ./patches/0004-accelerometer-support-SSC-accelerometer-sensor.patch
      ./patches/0005-compass-support-SSC-compass-sensor.patch
      ./patches/0006-accelerometer-apply-accel-attributes.patch
      ./patches/0007-data-add-libssc-udev-rules.patch
    ];
  };
}
