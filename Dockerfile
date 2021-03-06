FROM ubuntu:14.04
WORKDIR /build
# install tools and dependencies
RUN apt-get -y update && \
	apt-get install -y --force-yes --no-install-recommends \
	curl git make g++ gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
	libc6-dev-armhf-cross wget file ca-certificates \
	binutils-arm-linux-gnueabihf \
	&& \
    apt-get clean

# install multirust
RUN curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh -s -- --yes
ENV RUST_TARGETS="arm-unknown-linux-gnueabihf"
# multirust override beta
#RUN multirust override beta

# multirust add arm--linux-gnuabhf toolchain
RUN multirust add-target stable arm-unknown-linux-gnueabihf

# show backtraces
ENV RUST_BACKTRACE 1
# set compilers
ENV CXX arm-linux-gnueabihf-g++ 
ENV CC arm-linux-gnueabihf-gcc 
ENV ARCH arm
ENV CROSS_COMPILE arm-unknown-linux-gnueabihf
ENV TARGET arm-unknown-linux-gnueabihf
# build parity
RUN git clone https://github.com/ethcore/parity && \
	cd parity && \
	git checkout master && \
	mkdir -p .cargo && \
  	echo '[target.arm-unknown-linux-gnueabihf]\n\
	linker = "arm-linux-gnueabihf-gcc"\n'\
	>>.cargo/config && \
	cat .cargo/config && \
	rustc -vV && \

	cargo build --target arm-unknown-linux-gnueabihf --release --verbose && \
	ls /build/parity/target/arm-unknown-linux-gnueabihf/release/parity &&	\
	file /build/parity/target/arm-unknown-linux-gnueabihf/release/parity && \
	/usr/bin/arm-linux-gnueabihf-strip /build/parity/target/arm-unknown-linux-gnueabihf/release/parity
RUN file /build/parity/target/arm-unknown-linux-gnueabihf/release/parity
