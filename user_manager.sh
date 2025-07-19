if [ "$1" == "add" ]; then
    sudo useradd -m "$2"
    echo "Usuário $2 criado."
elif [ "$1" == "del" ]; then
    sudo userdel -r "$2"
    echo "Usuário $2 removido."
else
    echo "Uso: $0 [add|del] username"
fi