FROM ubuntu:20.04
WORKDIR /root/

ADD exp-gen.py /root/exp-gen.py
ADD hax.lua /root/hax.lua

RUN apt update && apt install wget build-essential python3-dev -y
RUN wget https://github.com/LuaJIT/LuaJIT/archive/refs/tags/v2.1.0-beta3.tar.gz
RUN tar -xvf v2.1.0-beta3.tar.gz && mv LuaJIT-2.1.0-beta3/ LuaJIT/ && rm -f v2.1.0-beta3.tar.gz
RUN cd LuaJIT/ && make && make install
RUN ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit

RUN ./exp-gen.py
CMD ["/bin/bash"]