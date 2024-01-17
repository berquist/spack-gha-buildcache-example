# `buildcache push` fails on macOS with non-zero environment `install_tree:padded_length`

## Steps to reproduce

On any version of macOS (`darwin-monterey-skylake`, `darwin-sonoma-m2`, ...), pushing to a buildcache when your environment tree has a non-zero install padding length fails.  It doesn't seem to fail on Linux, on macOS when there's no padding, or on macOS with padding but in the system config.

The files used to reproduce are at https://github.com/berquist/spack-gha-buildcache-example/tree/ff964ec28c5583c5df0915f9c7a1409544c5dcec using the `spack.yaml` and `install.sh` there:
```yaml
spack:
  view: my_view
  specs:
  - perl

  config:
    install_tree:
      padded_length: 128

  mirrors:
    personal-github:
      url: oci://ghcr.io/berquist/spack-gha-buildcache-example
      signed: false
```
```bash
spack env activate .  # done outside the script
spack concretize --force --fresh
spack install --fail-fast
spack -d buildcache push --rebuild-index --force personal-github
```

where the `spack.yaml` doesn't include my `access_pair`.

I was worried about the `multiprocessing` code interfering with debugging, so I also made changes locally as in https://github.com/berquist/spack-gha-buildcache-example/blob/ff964ec28c5583c5df0915f9c7a1409544c5dcec/debug.diff.

---

I'm not sure if this is related, but `spack buildcache list` gives
```console
$ spack buildcache list
==> Warning: The following issues were ignored while updating the indices of binary caches
  FetchIndexError: Remote index https://ghcr.io/v2/berquist/spack-gha-buildcache-example/manifests/index.spack is invalid
```

## Error message

When running an unpatched Spack (https://github.com/berquist/spack-gha-buildcache-example/blob/ff964ec28c5583c5df0915f9c7a1409544c5dcec/output_unmodified.log),
```
==> [2024-01-17-13:02:34.589741] Selected 12 specs to push to oci://ghcr.io/berquist/spack-gha-buildcache-example
==> [2024-01-17-13:02:34.635392] 12 specs need to be pushed to ghcr.io/berquist/spack-gha-buildcache-example
multiprocessing.pool.RemoteTraceback: 
"""
Traceback (most recent call last):
  File "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/multiprocessing/pool.py", line 125, in worker
    result = (True, func(*args, **kwds))
  File "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/multiprocessing/pool.py", line 51, in starmapstar
    return list(itertools.starmap(args[0], args[1]))
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 506, in _push_single_spack_binary_blob
    compressed_tarfile_checksum, tarfile_checksum = spack.oci.oci.create_tarball(spec, filename)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/oci/oci.py", line 41, in create_tarball
    buildinfo = spack.binary_distribution.get_buildinfo_dict(spec)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/binary_distribution.py", line 789, in get_buildinfo_dict
    manifest = get_buildfile_manifest(spec)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/binary_distribution.py", line 726, in get_buildfile_manifest
    visit_directory_tree(root, visitor)
  File "/Users/ejberqu/development/forks/spack/lib/spack/llnl/util/filesystem.py", line 1496, in visit_directory_tree
    dir_entries = sorted(os.scandir(dir), key=lambda d: d.name)
FileNotFoundError: [Errno 2] No such file or directory: '/Users/ejberqu/development/forks/spack/opt/spack/darwin-sonoma-m2/apple-clang-15.0.0/ncurses-6.4-nz36btw5cqv7k7j2aqfd3gwwzisj6gn4/'
"""

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/Users/ejberqu/development/forks/spack/bin/spack", line 52, in <module>
    sys.exit(main())
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack_installable/main.py", line 42, in main
    sys.exit(spack.main.main(argv))
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1066, in main
    return _main(argv)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1019, in _main
    return finish_parse_and_run(parser, cmd_name, args, env_format_error)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1049, in finish_parse_and_run
    return _invoke_command(command, parser, args, unknown)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 648, in _invoke_command
    return_val = command(parser, args)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 1143, in buildcache
    args.func(args)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 397, in push_fn
    skipped, base_images, checksums = _push_oci(
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 721, in _push_oci
    new_blobs = pool.starmap(
  File "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/multiprocessing/pool.py", line 372, in starmap
    return self._map_async(func, iterable, starmapstar, chunksize).get()
  File "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/multiprocessing/pool.py", line 771, in get
    raise self._value
FileNotFoundError: [Errno 2] No such file or directory: '/Users/ejberqu/development/forks/spack/opt/spack/darwin-sonoma-m2/apple-clang-15.0.0/ncurses-6.4-nz36btw5cqv7k7j2aqfd3gwwzisj6gn4/'
```

When running without the `multiprocessing` code, it appears to make it further (https://github.com/berquist/spack-gha-buildcache-example/blob/ff964ec28c5583c5df0915f9c7a1409544c5dcec/output_debug.log):
```
==> [2024-01-17-12:57:08.121062] Pushed perl@5.38.0/d2tmw4b to ghcr.io/berquist/spack-gha-buildcache-example:perl-5.38.0-d2tmw4bfqbbzfcmvrovul4plku4gbkkk.spack
==> [2024-01-17-12:57:09.351291] Already downloaded /var/folders/mv/cxdf9v7s4tj9_xrqn0bjmmhw0046c5/T/ejberqu/spack-stage/69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab/sha256:69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab
==> [2024-01-17-12:57:09.366609] ChecksumError: sha256 checksum failed for /var/folders/mv/cxdf9v7s4tj9_xrqn0bjmmhw0046c5/T/ejberqu/spack-stage/69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab/sha256:69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab
    Expected 69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab but got 709a870e862579355398c0115ec4d9995a48daf463ca066d671ca4f40afd9927. File size = 1564 bytes. Contents = b'<html>\n<head>\n<t...</body>\n</html>\n'
==> [2024-01-17-12:57:09.366693] Error: sha256 checksum failed for /var/folders/mv/cxdf9v7s4tj9_xrqn0bjmmhw0046c5/T/ejberqu/spack-stage/69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab/sha256:69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab
Expected 69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab but got 709a870e862579355398c0115ec4d9995a48daf463ca066d671ca4f40afd9927. File size = 1564 bytes. Contents = b'<html>\n<head>\n<t...</body>\n</html>\n'
Traceback (most recent call last):
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1066, in main
    return _main(argv)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1019, in _main
    return finish_parse_and_run(parser, cmd_name, args, env_format_error)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 1049, in finish_parse_and_run
    return _invoke_command(command, parser, args, unknown)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/main.py", line 648, in _invoke_command
    return_val = command(parser, args)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 1136, in buildcache
    args.func(args)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 485, in push_fn
    _update_index_oci(target_image, tmpdir, pool)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 785, in _update_index_oci
    spec_dicts = [_config_from_tag(image_ref, tag) for tag in tags if tag_is_spec(tag)]
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 785, in <listcomp>
    spec_dicts = [_config_from_tag(image_ref, tag) for tag in tags if tag_is_spec(tag)]
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/cmd/buildcache.py", line 770, in _config_from_tag
    _, config = get_manifest_and_config_with_retry(image_ref.with_tag(tag), tag, recurse=0)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/oci/opener.py", line 431, in wrapper
    return f(*args, **kwargs)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/oci/oci.py", line 344, in get_manifest_and_config
    stage.check()
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/stage.py", line 577, in check
    self.fetcher.check()
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/fetch_strategy.py", line 81, in wrapper
    return fun(self, *args, **kwargs)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/fetch_strategy.py", line 476, in check
    verify_checksum(self.archive_file, self.digest)
  File "/Users/ejberqu/development/forks/spack/lib/spack/spack/fetch_strategy.py", line 1429, in verify_checksum
    raise ChecksumError(
spack.fetch_strategy.ChecksumError: sha256 checksum failed for /var/folders/mv/cxdf9v7s4tj9_xrqn0bjmmhw0046c5/T/ejberqu/spack-stage/69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab/sha256:69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab
    Expected 69570b858c6239c4554bd73ad27fde37c0e9a8996984851be06b159969437aab but got 709a870e862579355398c0115ec4d9995a48daf463ca066d671ca4f40afd9927. File size = 1564 bytes. Contents = b'<html>\n<head>\n<t...</body>\n</html>\n'
```

## Information on your system

Without the debugging patch,
* **Spack:** 0.22.0.dev0 (bc9b39cb73a83219306e67191b560412155200d5)
* **Python:** 3.9.6
* **Platform:** darwin-sonoma-m2
* **Concretizer:** clingo
