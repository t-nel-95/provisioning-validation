FROM ubuntu:latest
LABEL maintainer="tristan"

# Install necessary packages: Python, pip, netaddr, SSH, and network utilities
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server python3 python3-pip iproute2 bridge-utils && \
    pip3 install netaddr --break-system-packages && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up SSH credentials and access
RUN mkdir /var/run/sshd
# Set password for the 'root' user to 'ansible'
RUN echo 'root:ansible' | chpasswd
# Allow root login via SSH password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Do not require DNS lookup (speeds up connection)
RUN echo "UseDNS no" >> /etc/ssh/sshd_config
EXPOSE 22
# Start the SSH service when the container launches
CMD ["/usr/sbin/sshd", "-D"]