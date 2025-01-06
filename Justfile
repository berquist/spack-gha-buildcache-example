export mirror_name := "github-container-registry"

default:
    eval "$(spack env activate --sh .)" && \
    spack mirror set \
        --oci-username ${GITHUB_ACTOR} \
        --oci-password ${GITHUB_TOKEN} \
        ${mirror_name} && \
    bash ./install.sh ${mirror_name}
    ./my_view/bin/python -c 'print("hello world")'
