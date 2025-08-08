#!/bin/bash
echo "九瓷的一键安装全家桶apt版"

if [ "$EUID" -eq 0 ]; then
    echo -e "\033[31m当前以超级用户权限执行\033[0m"
else
    echo "当前以普通用户权限执行"
fi

confirm_continue() {
    while true; do
        read -p "是否下载九瓷推荐常用软件包？(Y/n, 回车默认继续) : " choice
        if [ -z "$choice" ]; then
            echo "默认选择继续执行..."
            return 0
        fi
        
        case "$choice" in
            y|Y ) 
                echo " "
                return 0
                ;;
            n|N )
                echo "操作已取消"
                exit 1
                ;;
            * ) 
                echo "无效输入，请输入 Y/y 或 N/n（或直接回车继续）"
                ;;
        esac
    done
}

eat_dessert() {
    while true; do
        read -p "要吃甜点吗？[Y/n, 回车默认n不吃] : " choice
        local choice=${choice:-n}  
        
        case "$choice" in
            y|Y)
                echo "准备享用甜点..."
                
                # 获取用户输入的版本号
                while true; do
                    read -p "请输入甜点版本号（例如0,1,2...）: " version
                    if [[ "$version" =~ ^[0-9]+$ ]]; then
                        echo "您选择的版本是: $version"
                        break
                    else
                        echo -e "\033[31m错误：请输入有效的数字版本号\033[0m"
                    fi
                done
                
                mkdir -p "甜点"
                cd "甜点" || exit 1
                
                echo "正在下载甜点版本$version..."
                url="https://github.com/PtHntaeaaa/dessert/raw/main/0/milk-$version-.zip"
                
                if wget "$url"; then
                    echo "解压甜点..."
                    unzip "milk-$version-.zip"
                    rm "milk-$version-.zip"
                    echo -e "\033[32m甜点版本$version 已成功下载到: $(pwd)\033[0m"
                else
                    echo -e "\033[31m下载失败！请检查版本号是否正确或网络连接\033[0m"
                fi
                
                return 0
                ;;
            n|N)
                echo "跳过甜点下载"
                return 0
                ;;
            *)
                echo "无效输入，请输入 Y/y 或 N/n（或直接回车跳过）"
                ;;
        esac
    done
}

eat_dessert

confirm_continue

echo "继续执行..."
apt update
apt upgrade -y
apt -y install python3 wget unzip nmap git vim nano htop zsh eza emacs tree curl iproute2 fzf neofetch
neofetch

confirm_clear() {
    read -rp "全家桶安装完成，是否确认执行 clear? [Y/N] 回车不执行 : " answer
    
    answer="${answer,,}"
    
    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        echo "执行 clear..."
        clear
    elif [[ -z "$answer" || "$answer" == "n" || "$answer" == "no" ]]; then
        echo "取消执行 clear"
    else
        echo "错误：无效输入 '$answer'，请输入 Y 或 N"
        return 1
    fi
    return 0
}
confirm_clear