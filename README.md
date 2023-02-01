# wolfram-jupyter
Docker image with Jupyter Lab and Wolfram Language Engine kernel for Jupyter

## Distributed Software

The Docker image contains:

* Python 3.10
* [Wolfram Language Engine](https://www.wolfram.com/engine/) v13.2.0
   - Requires a [Free Wolfram Engine License](https://account.wolfram.com/access/wolfram-engine/free) which requires a Wolfram account
* Jupyter Lab
* [Wolfram Language kernel for Jupyter](https://github.com/WolframResearch/WolframLanguageForJupyter)

As I'm not sure if I can legally distribute a Docker image with my License agreement activated in it I won't put the image on Docker Hub, but you can build an image with your license agreement activated following these instructions.

## Build

Build requires [`docker buildx`](https://docs.docker.com/engine/reference/commandline/buildx/)

```bash
export WOLFRAM_ID="your Wolfram ID"
export WOLFRAM_PASSWORD="your Wolfram ID password"

docker buildx build . \
    --file Dockerfile \
    --build-arg BASE_IMAGE=wolframresearch/wolframengine:13.2.0 \
    --build-arg WOLFRAM_ID="${WOLFRAM_ID}" \
    --build-arg WOLFRAM_PASSWORD="${WOLFRAM_PASSWORD}" \
    --tag matthewfeickert/wolfram-jupyter:latest

unset WOLFRAM_ID
unset WOLFRAM_PASSWORD
```

## Use

```
docker run \
  --rm \
  -ti \
  --publish 8888:8888 \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  matthewfeickert/wolfram-jupyter:latest
```

## Examples

In a [notebook in the Wolfram Language Engine kernel](https://twitter.com/HEPfeickert/status/1620626979862216707?s=20&t=eiag_8Odc3xhV_3LvmFLiw) the following example commands work

```
$Version
13.2.0 for Linux x86 (64-bit) (December 12, 2022)
```
```
Plot3D[Sin[x y],{x,-Pi,Pi},{y,-Pi,Pi}]
```

as does the example use case given in [Nicolás Guarín-Zapata](https://github.com/nicoguaro) 2021-03-30 [blog post](https://nicoguaro.github.io/posts/wolfram_jupyter/):

[![example-notebook](https://user-images.githubusercontent.com/5142394/215956408-16281d32-e039-481e-a7b3-5fe413b05538.png)](https://nicoguaro.github.io/posts/wolfram_jupyter/)
