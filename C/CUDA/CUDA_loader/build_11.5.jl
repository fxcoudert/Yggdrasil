dependencies = [BuildDependency(PackageSpec(name="CUDA_full_jll", version=v"11.5.2"))]

script = raw"""
# First, find (true) CUDA toolkit directory in ~/.artifacts somewhere
CUDA_ARTIFACT_DIR=$(dirname $(dirname $(realpath $prefix/cuda/bin/ptxas${exeext})))
cd ${CUDA_ARTIFACT_DIR}

# Clear out our prefix
rm -rf ${prefix}/*

# license
install_license EULA.txt

# headers
mkdir -p ${prefix}/include
mv include/* ${prefix}/include
rm -rf ${prefix}/include/thrust

# binaries
mkdir -p ${bindir} ${libdir} ${prefix}/lib ${prefix}/share
if [[ ${target} == *-linux-gnu ]]; then
    # CUDA Runtime
    mv lib64/libcudart.so* lib64/libcudadevrt.a ${libdir}

    # CUDA FFT Library
    mv lib64/libcufft.so* lib64/libcufftw.so* ${libdir}

    # CUDA BLAS Library
    mv lib64/libcublas.so* lib64/libcublasLt.so* ${libdir}

    # CUDA Sparse Matrix Library
    mv lib64/libcusparse.so* ${libdir}

    # CUDA Linear Solver Library
    mv lib64/libcusolver.so* ${libdir}

    # CUDA Linear Solver Multi GPU Library
    mv lib64/libcusolverMg.so* ${libdir}

    # CUDA Random Number Generation Library
    mv lib64/libcurand.so* ${libdir}

    # NVIDIA Optimizing Compiler Library
    mv nvvm/lib64/libnvvm.so* ${libdir}

    # NVIDIA Common Device Math Functions Library
    mkdir ${prefix}/share/libdevice
    mv nvvm/libdevice/libdevice.10.bc ${prefix}/share/libdevice

    # CUDA Profiling Tools Interface (CUPTI) Library
    mv extras/CUPTI/lib64/libcupti.so* ${libdir}

    # NVIDIA Tools Extension Library
    mv lib64/libnvToolsExt.so* ${libdir}

    # Compute Sanitizer
    rm -r compute-sanitizer/{docs,include}
    mv compute-sanitizer/* ${bindir}

    # Additional binaries
    mv bin/ptxas ${bindir}
    mv bin/nvdisasm ${bindir}
    mv bin/nvlink ${bindir}
elif [[ ${target} == x86_64-w64-mingw32 ]]; then
    # CUDA Runtime
    mv bin/cudart64_*.dll ${bindir}
    mv lib/x64/cudadevrt.lib ${prefix}/lib

    # CUDA FFT Library
    mv bin/cufft64_*.dll bin/cufftw64_*.dll ${bindir}

    # CUDA BLAS Library
    mv bin/cublas64_*.dll bin/cublasLt64_*.dll ${bindir}

    # CUDA Sparse Matrix Library
    mv bin/cusparse64_*.dll ${bindir}

    # CUDA Linear Solver Library
    mv bin/cusolver64_*.dll ${bindir}

    # CUDA Linear Solver Multi GPU Library
    mv bin/cusolverMg64_*.dll ${bindir}

    # CUDA Random Number Generation Library
    mv bin/curand64_*.dll ${bindir}

    # NVIDIA Optimizing Compiler Library
    mv nvvm/bin/nvvm64_*.dll ${bindir}

    # NVIDIA Common Device Math Functions Library
    mkdir ${prefix}/share/libdevice
    mv nvvm/libdevice/libdevice.10.bc ${prefix}/share/libdevice

    # CUDA Profiling Tools Interface (CUPTI) Library
    mv extras/CUPTI/lib64/cupti64_*.dll ${bindir}

    # NVIDIA Tools Extension Library
    mv bin/nvToolsExt64_1.dll ${bindir}

    # Compute Sanitizer
    rm -r compute-sanitizer/{docs,include}
    mv compute-sanitizer/* ${bindir}

    # Additional binaries
    mv bin/ptxas.exe ${bindir}
    mv bin/nvdisasm.exe ${bindir}
    mv bin/nvlink.exe ${bindir}

    # Fix permissions
    chmod +x ${bindir}/*.{exe,dll}
fi
"""

products = [
    LibraryProduct(["libnvvm", "nvvm64_40_0"], :libnvvm),
    LibraryProduct(["libcufft", "cufft64_10"], :libcufft),
    LibraryProduct(["libcublas", "cublas64_11"], :libcublas),
    LibraryProduct(["libcusparse", "cusparse64_11"], :libcusparse),
    LibraryProduct(["libcusolver", "cusolver64_11"], :libcusolver),
    LibraryProduct(["libcusolverMg", "cusolverMg64_11"], :libcusolverMg),
    LibraryProduct(["libcurand", "curand64_10"], :libcurand),
    LibraryProduct(["libcupti", "cupti64_2021.3.1"], :libcupti),
    LibraryProduct(["libnvToolsExt", "nvToolsExt64_1"], :libnvtoolsext),
    FileProduct(["lib/libcudadevrt.a", "lib/cudadevrt.lib"], :libcudadevrt),
    FileProduct("share/libdevice/libdevice.10.bc", :libdevice),
    ExecutableProduct("ptxas", :ptxas),
    ExecutableProduct("nvdisasm", :nvdisasm),
    ExecutableProduct("nvlink", :nvlink),
    ExecutableProduct("compute-sanitizer", :compute_sanitizer),
]

platforms = [Platform("x86_64", "linux"; cuda="11.5"),
             Platform("powerpc64le", "linux"; cuda="11.5"),
             Platform("aarch64", "linux"; cuda="11.5"),
             Platform("x86_64", "windows"; cuda="11.5")]
