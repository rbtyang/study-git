#!/bin/sh

#reference
#- elif: https://blog.csdn.net/m0_37138008/article/details/72814543
#- str match by operator: https://blog.csdn.net/iamlihongwei/article/details/59484029
#- str extract by sed: https://blog.csdn.net/tp7309/article/details/51418412
#- sed manual: https://www.runoob.com/linux/linux-comm-sed.html
#- git pre-commit hook: https://juejin.im/post/5addeb48518825672a028a3b

#git remote repo
#- git@github.com:rbtyang/study-git.git
#- https://github.com/rbtyang/study-git.git

#gitee remote repo
#- https://gitee.com/BenDanXianSheng/excel_relyon.git
#- git@gitee.com:BenDanXianSheng/excel_relyon.git

#git remote img
#- https://raw.githubusercontent.com/[_GIT_REPO_]/[_GIT_BRAN_]/[_IMG_PATH_]
#- https://raw.githubusercontent.com/rbtyang/study-git/master/test/20200106100811032.jpg

#gitee remote img
#- https://gitee.com/[_GIT_REPO_]/raw/[_GIT_BRAN_]/[_IMG_PATH_]
#- https://gitee.com/cofedream/Cofe_Mybatis/raw/master/images/SpringInject.gif

GIT_URL=$(git remote get-url origin)


GIT_PLTF
if [[ $GIT_URL =~ 'github' ]]; then
	GIT_PLTF='github'
	GIT_IMG_FMT='https://raw.githubusercontent.com/_GIT_REPO_/_GIT_BRAN_/_IMG_PATH_'
elif [[ $GIT_URL =~ 'gitee' ]]; then
	GIT_PLTF='gitee'
	GIT_IMG_FMT='https://gitee.com/_GIT_REPO_/raw/_GIT_BRAN_/_IMG_PATH_'
else
    echo ">>> GIT: undefined git platform"
    exit 1
fi
echo ">>> GIT: platform -> ${GIT_PLTF}"
echo ">>> GIT: img format -> ${GIT_IMG_FMT}"


if [[ $GIT_URL =~ 'https' ]]; then
    echo ">>> GIT: remote url -> ${GIT_URL}"
    #> echo https://github.com/rbtyang/study-git.git |sed 's/.*com\/\(.*\).git.*/\1/g' #rbtyang/study-git
    GIT_REPO=$(echo $GIT_URL |sed 's/.*com\/\(.*\).git.*/\1/g')
else
    echo ">>> GIT: remote url -> ${GIT_URL}"
    #> echo git@github.com:rbtyang/study-git.git |sed 's/.*com:\(.*\).git.*/\1/g' #rbtyang/study-git
    GIT_REPO=$(echo $GIT_URL |sed 's/.*com:\(.*\).git.*/\1/g')
fi
echo ">>> GIT: repo name -> ${GIT_REPO}"

# exit 1

GIT_BRAN=$(git symbolic-ref --short -q HEAD)
echo ">>> GIT: curl branch -> ${GIT_BRAN}"


IMG_PATH=''
GIT_REPO=$(echo $GIT_REPO |sed 's/\//\\\//g') #需要将 / 替换为 \/
GIT_IMG_RAW=$(
	echo $GIT_IMG_FMT \
	|sed "s/_GIT_REPO_/${GIT_REPO}/g" \
	|sed "s/_GIT_BRAN_/${GIT_BRAN}/g" \
	|sed "s/_IMG_PATH_/${IMG_PATH}/g"
)
echo ">>> GIT: img url raw -> ${GIT_IMG_RAW}"
GIT_IMG_RAW=$(echo $GIT_IMG_RAW |sed 's/\//\\\//g') #需要将 / 替换为 \/

STAGE_FILES=$(git diff --cached --name-only -z --diff-filter=ACM -- '*.md' |xargs -0)
echo -e "\nSTAGE_FILES: ${STAGE_FILES}"

# exit 1

if test ${#STAGE_FILES} -gt 0; then
	for STA_FILE in $STAGE_FILES
	do
		echo -e "\n>>> STA_FILE: ${STA_FILE} ------------"

		if [[ $STA_FILE =~ 'hooks' ]]; then
			continue
		fi

		#local img
		#- ![](assets/yoy-time-all.png)
		#- ![imgalt](assets/yoy-time-all.png)
		#- ![](./assets/yoy-date-store.png)
		#- ![](../../qweqwe/../qweqwe/asd/teqe.jpg)

 		#还没找到排除 ![image](https://raw...) 的方法，为了避免重复生成拼接的 url
 		#因此，这里先把原来的 ![image](https://raw...) 恢复为 ![image](assets/yoy-date-store.png) 这种格式，后面再统一重新生成
		# cat README.md |sed 's/https:\/\/raw.githubusercontent.com\/rbtyang\/study-git\/master\///g'
		sed -i "s/${GIT_IMG_RAW}//g" $STA_FILE

		#统一重新生成 ![image](https://raw...)
		# cat README.md |sed 's/.*\!\[.*\](\(.*\)).*/\1/g' #./assets/yoy-date-store.png
		# cat $STA_FILE |sed "s/.*\!\[.*\](\(.*\)).*/\1/g" #./assets/yoy-date-store.png
		# cat $STA_FILE |grep -v 'http' |sed "s/.*\!\[.*\](\(.*\)).*/\1/g" #./assets/yoy-date-store.png
		# cat $STA_FILE |grep -v 'http' |sed "s/.*\!\[.*\](\(.*\)).*/![image](${GIT_IMG_RAW}\1)/g" #./assets/yoy-date-store.png
		sed -i "s/.*\!\[.*\](\(.*\)).*/![image](${GIT_IMG_RAW}\1)/g" $STA_FILE
  	done
else
	echo 'There are no files to check'
fi

git add .