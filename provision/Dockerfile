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
# Create the .ssh directory for the root user to hold authorized_keys
RUN mkdir -p /root/.ssh

# Set a temporary password ('ansible') for the 'root' user.
RUN echo 'root:ansible' | chpasswd
# Allow root login via SSH password.
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Do not require DNS lookup (speeds up connection)
RUN echo "UseDNS no" >> /etc/ssh/sshd_config
EXPOSE 22
# Start the SSH service when the container launches
# The CMD is now simpler as it only needs to start the SSH server.
CMD ["/usr/sbin/sshd", "-D"]