clear
echo "==============================================="
echo "             Server Setup (UBUNTU)"
echo "==============================================="
echo
echo
echo "    Welcome to the server setup for UBUNTU"
echo
echo
echo "============= Pre install checks =============="
sleep 5
if [[ $EUID -ne 0 ]]; then
echo "[ERROR] This script has exited. Error: User is not root." 1>&2
exit 1
fi
echo "OK"
sleep 1
echo "Checks complete."
echo "========== Installing Required DEPS ==========="
sleep 1
apt install nodejs npm -y
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc
apt install python3 pip -y
echo "Checking version....."
sleep 1
echo "Node.JS VERSION:"
node --version
sleep 1
echo "Python VERSION:"
python3 --version
sleep 1
echo "PNPM VERSION:"
pnpm --version
sleep 1
echo "If no version emerges, check your OS and manually install."
sleep 5
echo
echo "========= Finished! =========="
echo
echo
echo
echo "================================================"
echo
echo
echo " Installer Completed! Thanks for using the tool"
echo " No reboot neccecary. all are installed."
echo
echo
echo "================================================"
