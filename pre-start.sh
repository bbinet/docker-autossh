#!/bin/bash

# Import our environment variables from systemd
while IFS= read -rd '' var; do export "$var"; done </proc/1/environ

abort() {
    msg="$1"
    echo "$msg"
    echo "=> Environment was:"
    env
    echo "=> Program terminated!"
    exit 1
}

create_user() {
    user=$1
    password=$2
    if [ -z "${user}" ] || [ -z "${password}" ]; then
        abort "=> create_user 2 args are required (user, password)."
    fi
    useradd --create-home --shell /bin/bash ${user}
    echo "${user}:${password}" | chpasswd
    if [ $? -eq 0 ]; then
        echo "${user} ALL=(ALL) NOPASSWD: /usr/local/sbin/cleanup_port.sh" >> /etc/sudoers.d/91-custom-sudo-users
        echo "alias _cleanup_port='sudo /usr/local/sbin/cleanup_port.sh'" > /home/${user}/.bash_aliases
        echo "=> User \"${user}\" ok."
    else
        abort "=> Failed to create user \"${user}\"!"
    fi
}

# setup autossh authorized_keys
if [ -f $AUTOSSH_PUBKEY_PATH ]; then
    echo "command=\"/usr/local/bin/sleep.sh\",no-agent-forwarding,no-X11-forwarding,no-pty,no-user-rc $(cat $AUTOSSH_PUBKEY_PATH)" > /var/lib/autossh/.ssh/authorized_keys
    chmod 600 /var/lib/autossh/.ssh/authorized_keys
    chown autossh:autossh /var/lib/autossh/.ssh/authorized_keys
else
    abort "=> Cannot find autossh pub key at: \"$AUTOSSH_PUBKEY_PATH\""
fi

# create users from environment variables and docker secrets
if [ -z "${PRE_CREATE_USERS}" ]; then
    echo "=> No user names supplied: no user will be created."
    rm -f /etc/sudoers.d/91-custom-sudo-users
else
    > /etc/sudoers.d/91-custom-sudo-users
    chmod 440 /etc/sudoers.d/91-custom-sudo-users
    for user in $(echo ${PRE_CREATE_USERS} | tr "," "\n"); do
        if [ -f "/run/secrets/${user}.password" ]
        then
            create_user $user $(cat "/run/secrets/${user}.password")
        else
            userpassword_var="${user}_PASSWORD"
            create_user $user ${!userpassword_var}
        fi
    done
fi
