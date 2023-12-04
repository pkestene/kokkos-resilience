# What is `kokkos-resilience_dependencies`

This is just a small cmake sub-project that only aims at facilitating the build of some optional or required dependencies of kokkos-resilience.

## Quick start

Example of use when building only `p4est`:

```shell
# from kokkos-resilience top-level source directory
mkdir -p _build/dependencies
cd _build/dependencies
cmake ../../dependencies
make
```

By default, all dependencies will be installed in `$HOME/.kokkos-resilience_dependencies`.
You can change that by setting cmake variable `CMAKE_INSTALL_PREFIX`.

Additionnally, a modulefile is also provided; once you built all chosen dependencies,
you just need to do the following:

```shell
module use ~/.kokkos-resilience_dependencies/share/modulefiles
module use kokkos-resilience_dependencies/1.0
```

and you're good to go building `kokkos-resilience` with this dependencies.

## List of dependencies

Here is the list of dependencies that can be built:

- [kvtree](https://github.com/ECP-VeloC/KVTree)
- [rankstr](https://github.com/ECP-VeloC/rankstr)
- [redset](https://github.com/ECP-VeloC/redset)
- [shuffile](https://github.com/ECP-VeloC/shuffile)
- [er](https://github.com/ECP-VeloC/er)
- [axl](https://github.com/ECP-VeloC/AXL)
- [veloc](https://github.com/ECP-VeloC/VELOC)

## Some features

### Specify source to compile

For most dependencies, you can chose which source you want to build, either a git tag or release archive (remote or local file).

E.g. if you already have downloaded a KVTree archive, you can configure `kokkos-resilience_dependencies` using cmake var `kokkos-resilience_KVTREE_SOURCE_ARCHIVE` to specify the tarball path on your local machine.

```shell
# from kokkos-resilience top-level source directory
mkdir -p _build/dependencies
cd _build/dependencies
cmake -Dkokkos-resilience_KVTREE_BUILD=ON -Dkokkos-resilience_KVTREE_SOURCE_ARCHIVE=$HOME/kvtree-0.5.0 ../../dependencies
make
```

Warning: don't use `~` in the archive filepath, because this is passed to cmake as a string, that can either be a local filesystem path or a remote url; just the full path, of `$HOME`.

### Recompile a dependency

Suppose you want to recompile e.g. `rankstr`, just remove directory `external/rankstr` and re-execute cmake configure and then `make` again.

We also advise you to also clean the install location (default is $HOME/.kokkos-resilience_dependencies), to make sure to restart in a clean directory.

### dependencies of dependencies

Currently all dependencies listed above are independent one for another, but we could have the situation where two dependencies actually depend from a third one. In this, this actually possible since cmake macro `ExternalProject_Add` can manage dependencies upon completion of another `ExternalProject_Add`.
