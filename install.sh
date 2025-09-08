# install.sh
#!/bin/bash
set -e

USER_NAME="kiosk"

echo "==> Обновляем пакеты..."
sudo apt update && sudo apt upgrade -y

echo "==> Устанавливаем Xorg, Openbox и прочее..."
sudo apt install -y \
  xorg openbox xinit unclutter florence chromium-browser

echo "==> Создаём директории конфигурации..."
sudo -u $USER_NAME mkdir -p /home/$USER_NAME/.config/openbox

echo "==> Создаём autostart для Openbox..."
cat << 'EOF' | sudo -u $USER_NAME tee /home/$USER_NAME/.config/openbox/autostart > /dev/null
#!/bin/bash
# ~/.config/openbox/autostart

# Скрываем курсор
unclutter -idle 0 &

# Запуск экранной клавиатуры с авто-показом
florence --no-panel --auto-show &

# Настройки энергосбережения X
xset -dpms
xset s off
xset s 3600

# Небольшая пауза
sleep 3

# Запуск Chromium в киоск-режиме с масштабом 70%
chromium-browser --kiosk http://192.168.7.1:5000/ \
  --noerrdialogs --disable-infobars --force-device-scale-factor=0.7 \
  --disable-translate &
EOF

sudo chmod +x /home/$USER_NAME/.config/openbox/autostart

echo "==> Включаем автологин пользователя $USER_NAME..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

echo "==> Готово!"
echo "Перезагрузите систему командой: sudo reboot"
