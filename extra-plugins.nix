{
  inputs,
  plover,
  hid,
  bitarray,
  setuptools,
  buildPythonPackage,
}:
{
  plover-machine-hid = buildPythonPackage {
    pname = "plover-machine-hid";
    version = "master";
    src = inputs.plover-machine-hid;
    pyproject = true;
    build-system = [ setuptools ];
    buildInputs = [ plover ];
    dependencies = [
      hid
      bitarray
    ];
  };
}
