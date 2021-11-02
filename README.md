# organicmaps (previously omim)

Manual builds of the https://github.com/organicmaps/organicmaps/ based on Python image

The build triggers on tags and tags are to match `YYYY.MM.DD(-AA-BC)` (we refer to them as `release-XXX` for the purpose of this documentation) tags in https://github.com/organicmaps/organicmaps/
Example:
* source: release-95; this repo: release-95-base followed with release-95; DockerHub: release-95-base (first step) and release-95, release-95-full, latest, release-95-full-debug (skipped), release-95-generator, release-95-generator-debug (skipped) on second step
* source: release-96; this repo: release-96-base followed with release-96; DockerHub: release-96-base (first step) and release-96, release-96-full, latest, release-96-full-debug (skipped), release-96-generator, release-96-generator-debug (skipped) on second step

**IMPORTANT**: Due performance issues with DockerHub Automated Build these builds are separated!

The build process (previously it was Docker Hub Automated Build) is two steps for a reason as outlined above. Unfortunately, it also caused the dirty hooks conditions as we need decide what step we are at. Input is very welcome!

First of all we need to prepare base image by creating tag `release-XXX-base`. In few hours (!) we get the DockerHub base image `alexkuzko/organicmaps` with tag `release-XXX-base`.
It is possible to omit the creation of `release-XXX-base` tag and directly build and push it to save time by executing `build.sh` script from the root of this repository (this repository and Docker Hub Registry owner only).

Second step triggered by creating tag `release-XXX` to build DockerHub image `alexkuzko/organicmaps`  with primary tag `release-XXX` (it also tagged as `release-XXX-full` and `latest`). Additionally we build images with tags `release-XXX-full-debug`, `release-XXX-generator` and `release-XXX-generator-debug`.
**IMPORTANT**: Same performance issue affects automated build, the script `build.sh` may be used to perform local build.

**DEBUG BUILDS**: Due build issues with debig builds (they fail too often) they are no longer built/pushed automatically via `hooks/post_build / hooks/post_push` scripts unless argument passed. This means it may be built only using `build.sh` with additional second param passed.

**TESTS SKIP**: Due to the issue described in https://github.com/organicmaps/organicmaps/issues/1436 we need to add `CMAKE_CONFIG=-DSKIP_TESTS=true` during the release build.

Automated Build were setup to trigger on:

Base image:
* Source Type: Tag
* Source: `/^(release-[0-9]+)-base$/`
* Docker Tag: `{\1}-base`
* Dockerfile location: Dockerfile
* Build Context: /
* Build Caching: Yes

Production images:
* Source Type: Tag
* Source: `/^(release-[0-9]+)$/`
* Docker Tag: `{\1}`
* Dockerfile location: Dockerfile.release
* Build Context: /
* Build Caching: Yes

## Examples

In order to run you need to prepare the environment first by creating scratch (temporary) directory and target/source directories.

Optionally you need to pass map_generator.ini to override default value for planet (map).
To get the default file execute this command:
```
docker run --rm alexkuzko/organicmaps cat /root/organicmaps/tools/python/maps_generator/var/etc/map_generator.ini
```
Then either fill it with `PLANET_URL` and `PLANET_MD5_URL` directly from geofabrik or use the local maps from source directory.

Geofabrik example:
```
PLANET_URL: https://download.geofabrik.de/europe/moldova-latest.osm.pbf
PLANET_MD5_URL: https://download.geofabrik.de/europe/moldova-latest.osm.pbf.md5
```

Local example:
```
PLANET_URL: file:///srv/source/moldova-latest.osm.pbf
PLANET_MD5_URL: file:///srv/source/moldova-latest.osm.pbf.md5
```

**NOTE**: Coasts file may be passed in similar way. Generator expect them to be named as: `latest_coasts.geom` and `latest_coasts.rawgeom`

The partial command (it just opens the shell, generator example is below):
```
docker run -v /PATH/TO/SCRATCH/root:/root/maps_build -v /PATH/TO/SCRATCH/target:/srv/target -v /PATH/TO/SOURCE:/srv/source -v /PATH/TO/OPTIONAL/CONFIG:/root/organicmaps/tools/python/maps_generator/var/etc/map_generator.ini -it alexkuzko/organicmaps:$VERSION"
```

The one-liner command to generate Moldova map:
```
docker run -v /PATH/TO/SCRATCH/root:/root/maps_build -v /PATH/TO/SCRATCH/target:/srv/target -v /PATH/TO/SOURCE:/srv/source -v /PATH/TO/OPTIONAL/CONFIG:/root/organicmaps/tools/python/maps_generator/var/etc/map_generator.ini -it alexkuzko/organicmaps:$VERSION" bash -c "python3 -m maps_generator --countries=\"Moldova\" --skip=ExternalResources,UpdatePlanet,Coastline,Srtm,IsolinesInfo
```

**NOTE**: It is highly advised to use `--countries="FIRST,SECOND,etc."` as an option to limit the map(s) to be created.

## TODO

Optimize the resulting build. One of the option is to remove everything from 3party (and probably other directories) and keep tools directory only.
Need to get information from the community before doing such a change.
