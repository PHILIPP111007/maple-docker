# MAPLE Docker Image

## 1. Подготовка

```bash
git clone https://github.com/PHILIPP111007/maple-docker.git
cd maple-docker
git clone https://github.com/Drizzle-Zhang/MAPLE.git
cd -
```

## 2. Сборка образа

```bash
chmod +x build.sh
./build.sh
```

## 3. Train

```bash
bash ./run_training.sh \
    -d /Users/phil/Downloads/epiAge_traindata.npz \
    -o /Users/phil/Downloads/Output \
    -c /Users/phil/Downloads/MAPLE_ckpt
```
