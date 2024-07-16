# Arch linux

## Содержание

- [Введение](#Введение)
- [Установка](#Установка)
- [Пакеты-Python](#Пакеты-Python)
- [Forks](#Forks)
- [License](#License)

## Введение

Данный репозиторий посвещён [спину](https://cyclowiki.org/wiki/Spin_(операционная_система)) независимо разрабатываемого x86-64 дистрибутива GNU/Linux общего назначени - [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux_(Русский)). Данный спин использует в качестве оконого менеджера [Hyprland](https://hyprland.org/) - это основанный на wlroots tiling Wayland композитор.  

- Shell - Fish

## Установка

Для установки необходимо подготовить загрузочный USB с образом Arch Linux, к примеру образ можно загрузить на USB с помощью Rufus для Windows:

- [Arch Linux](https://archlinux.org/download/)
- [Rufus](https://rufus.ie/ru/)

1. После подготовки, настраиваем BIOS, обязательно необходимо включить UEFI и в меню BOOT выбрать основным устройством USB с образом Arch Linux. Сохраняем и перезапускаем.

2. После перезапуска должно появится окно установки Arch Linux. Выбираем пункт "Arch Linux install medium (x86_64, x64 UEFI)".

3. После того как образ подготовился к установки, появляется в строке "root@archiso", устанавливаем git и делаем клон данного репозитория:

```sh
pacman -Sy --noconfirm git
```

```sh
git clone https://github.com/Your-RoGr/arch-linux-rogr.git
```

4. После переходим в папку с git, даём права на исполнение и запускаем установщик (процесс утановки занимает несколько минут, зависит от скорости интернета и скорости работы ROM):

```sh
cd arch-linux-rogr
```

```sh
chmod +x arch-installer.sh
```

```sh
./arch-installer.sh
```

5. Далее нужно вписать своё имя пользователя, имя компьютера, выбрать диск из предложенных, выбрать [Часовой пояс](https://www.howtosop.com/linux-all-available-time-zones/), со всеми вопросами соглашаемся (убедитесь, что выбрали правильно диск под систему). По возможности, можете самостоятельно отформатировать диски как нужно, а после запускать установку, для этого вместо диска пишем skip. По стандарту создаётся два раздела:

- fat32 1MiB 513MiB (/boot)
- ext4 513MiB 100% (/)

6. Далее в процессе установки потребуется указать пароль root и пользователя

7. В конце перезагружаем компьютер после появления надписи (если компьютер сам не выключился) и в BIOS в BOOT выбираем основным устройством диск с /boot:

```sh
[ OK ] Reached target System Power Off
```

8. Далее входим под своим пользователем и снова делаем клон данного репозитория:

```sh
git clone https://github.com/Your-RoGr/arch-linux-rogr.git
```

9. После переходим в папку с git, даём права на исполнение и запускаем пост установщик (процесс утановки занимает значительное время, зависит от скорости интернета и скорости работы ROM):

```sh
cd arch-linux-rogr
```

```sh
chmod +x arch-post-installation.sh
```

```sh
./arch-post-installation.sh
```

10. В начале установки потребуется выбрать видео драйвер (1 - nvidia (для GTX 750 и новее), 2 - amd), или skip если ваша видеокарта не подходит под требования (установите драйвера вручную).

11. Дождитесь конца установки и наслаждайтесь использованием Arch Linux с Hyprland!

> Возможно потребуется перезагрузка

### Дополнительно

1. Можно установить CUDA (Если у вас видеокарта GTX 1050 и новее):

```sh
./cuda-installer.sh
```

2. Можно настроить пользователя postgres для PostgreSQL:

```sh
sudo su - postgres
```

```sh
psql -c "alter user postgres with password 'postgres'"
```

```sh
exit
```

## Пакеты-Python

Можете ознакомится с пакетами Python и изменить их при необходимсоти в requirements.txt. Дополнительная информация в [PyPI](https://pypi.org/) или в документациях разработчиков пакетов.

## Forks

На данный момент существуют доверенные форки спина:

- [arch-linux](https://github.com/Your-RoGr/arch-linux)
- [arch-linux-rogr](https://github.com/Your-RoGr/arch-linux-rogr)
- [arch-linux-ML](https://github.com/Your-RoGr/arch-linux-ML)
- [arch-linux-extra](https://github.com/Extragenchik/arch-linux-extra)

## License

MIT

**Free Software, Hell Yeah!**