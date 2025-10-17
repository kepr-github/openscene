# syntax=docker/dockerfile:1.4
FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive \
    FORCE_CUDA=1 \
    TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0"

WORKDIR /workspace

RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list 2>/dev/null || true

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    libopenblas-dev \
    libopenexr-dev \
    libgl1 \
    cmake \
    && (apt-get purge -y python3-yaml || true) \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir "pip<23" \
    && pip install --no-cache-dir --ignore-installed PyYAML \
    && pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir \
        torch==1.7.1+cu110 \
        torchvision==0.8.2+cu110 \
        torchaudio==0.7.2 \
        -f https://download.pytorch.org/whl/torch_stable.html

RUN pip install --no-cache-dir git+https://github.com/NVIDIA/MinkowskiEngine --no-deps \
        --install-option="--force_cuda" \
        --install-option="--blas=openblas"

# Optional dependency used by some workflows.
RUN pip install --no-cache-dir tensorflow

COPY . .

ENV PYTHONPATH="/workspace:${PYTHONPATH}"
