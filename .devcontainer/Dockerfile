FROM greyltc/archlinux

RUN pacman -Syu --noconfirm \
            wget \
    && find /var/cache/pacman/ -type f -delete

RUN pacman -Sy --noconfirm --overwrite "*libedit*,*readline.h,*histedit.h" libedit
RUN pacman -Sy --noconfirm git
RUN pacman -Sy --noconfirm iverilog
RUN pacman -Sy --noconfirm verilator
RUN pacman -Sy --noconfirm make 