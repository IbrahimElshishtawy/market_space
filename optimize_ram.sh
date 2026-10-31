#!/usr/bin/env bash
# ==============================================================================
# Linux RAM Speed & Responsiveness Optimizer
# سكريبت تسريع وتخفيف ضغط الرام على أوبونتو
# ==============================================================================

set -e

# ألوان الطرفية
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}======================================================${RESET}"
echo -e "${GREEN}   أداة تسريع استجابة الرام وتخفيف ضغط Swap (Ubuntu)   ${RESET}"
echo -e "${CYAN}======================================================${RESET}\n"

# التحقق من صلاحيات root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] يجب تشغيل هذا السكريبت بصلاحيات root:${RESET}"
  echo -e "    ${YELLOW}sudo bash optimize_ram.sh${RESET}\n"
  exit 1
fi

echo -e "${CYAN}[1/4] تنظيف الكاش والذاكرة المؤقتة القديمة...${RESET}"
# تفريغ الكاش غير المستخدم بأمان
sync
echo 3 > /proc/sys/vm/drop_caches
echo -e "${GREEN}✔ تم تنظيف PageCache و Dentries بأمان.${RESET}\n"

echo -e "${CYAN}[2/4] تفريغ الذاكرة البطيئة من Swap وإعادتها للرام السريعة...${RESET}"
echo -e "${YELLOW}جاري إعادة تدوير Swap (قد يستغرق 10-20 ثانية حسب كمية البيانات)...${RESET}"
swapoff -a
swapon -a
echo -e "${GREEN}✔ تم تفريغ Swap وإعادة البرامج النشطة إلى شريحة الرام السريعة.${RESET}\n"

echo -e "${CYAN}[3/4] ضبط حساسية النواة (Swappiness = 10) للاعتماد على الرام الفيزيائية...${RESET}"
# تطبيق فوري
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50

# تثبيت الإعدادات بشكل دائم في /etc/sysctl.d/99-ram-optimization.conf
CONF_FILE="/etc/sysctl.d/99-ram-optimization.conf"
cat << 'EOF' > "$CONF_FILE"
# تحسين سرعة الرام وتقليل اللجوء إلى التخزين البطيء
vm.swappiness = 10
vm.vfs_cache_pressure = 50
EOF

echo -e "${GREEN}✔ تم تثبيت vm.swappiness=10 و vfs_cache_pressure=50 بشكل دائم.${RESET}\n"

echo -e "${CYAN}[4/4] حالة الذاكرة الحالية بعد التسريع:${RESET}"
echo "------------------------------------------------------"
free -h
echo "------------------------------------------------------"

echo -e "\n${GREEN}✔ اكتملت عملية التحسين بنجاح! ستلاحظ سرعة وخفة فورية في استجابة النظام والبرامج.${RESET}\n"
