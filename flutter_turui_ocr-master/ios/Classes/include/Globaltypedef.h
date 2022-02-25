/**
 * @file            Globaltypedef.h
 * @brief        OCR识别引擎定义内容
 * @author        Vincent
 * @date            2019-06-20
 * @version        7.4.0
 * @copyright    厦门市图睿信息科技有限公司
 */

#ifndef GLOBAL_TYPEDEF
#define GLOBAL_TYPEDEF
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/// 接口导出宏定义开头
#ifndef _API_EXPORTS
#define _API_EXPORTS
#endif

/// 接口导出宏
#if defined _API_EXPORTS && defined _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__ ((visibility("default")))
#endif


/// 用于设置 @ref TCFGINFO 结构标识，以识别指针类型
#define CFG_INFO_SIGN    "tr_config_information_struct_sign"

#define LENTH_128                128
#define LENTH_256                256
#define LENTH_512                512

/************************************************************************\
 *                         内部一些数据长度的限制                         *
 \************************************************************************/
/// 版本号最大长度
#define LENTH_VERSION_MAX        64
/// 加载路径最大长度
#define MAX_LENGTH_PATH            260

/*银行卡识别结果导出结构*/
/// 卡号的最大长度限制
#define MAX_LENTH_CARDNUM        32
/// 版本信息最大长度限制
#define MAX_LENTH_VERSIONINFO    LENTH_VERSION_MAX
/// 卡名最大长度限制
#define MAX_LENTH_BANKNAME        64
/// 卡种最大长度限制
#define MAX_LENTH_CARDCLASS        16


/************************************************************************\
 *                         系统自定义基础数据类型                         *
 \************************************************************************/
///识别句柄主指针
typedef void *            TR_HANDLE;
///无符号字符型 0 ~ 255(0xff)
typedef unsigned char    Gbyte;
///无符号短整形0 ~ 65535(0xffff)
typedef unsigned short    UShort;
///无符号短整型0 ~ 65535(0xffff)
typedef unsigned short    Ushort;
///短整型 -32768 ~ 32767
typedef short            Gshort;
///整形 2147483647~-2147483648
typedef int                Gint;
///长整形 -2147483648〜2147483647
typedef long            Glong;
///无符号长整形 0 ~ 4294967295
typedef unsigned long    ULong;
///无符号整形 0 ~ 4294967295
typedef unsigned int    UInt;
///回调函数定义
typedef int (*f_progress)(char *p);


/************************************************************************\
 *                        证件类型、字段及属性标签                        *
 \************************************************************************/
/**
 * @brief 支持的证件类型枚举
 */
typedef enum
{
	TUNCERTAIN            = 0x00,                /**< 未知*/
	TIDCARD2            = 0x11,                /**< 二代证*/
	TIDCARDBACK            = 0x14,                /**< 二代证背面*/
	TIDBANK                = 0x15,                /**< 银行卡*/
	TIDLPR                = 0x16,                /**< 车牌*/
	TIDJSZCARD            = 0x17,                /**< 驾照*/
	TIDXSZCARD            = 0x18,                /**< 行驶证*/
	TIDTICKET            = 0x19,                /**< 火车票*/
	TIDSSCCARD            = 0x20,                /**< 社保卡*/
	TIDPASSPORT            = 0x21,                /**< 护照*/
	TIDDRILL            = 0x22,                /**< 钻孔柱状图*/
	TIDBIZLIC            = 0x23,                /**< 营业执照*/
	TIDINVOICE            = 0x24,                /**< 增值税发票*/
	TIDDOCUMENT            = 0x25,                /**< 通用文档*/
	TIDRMB                = 0x26,                /**< 人民币*/
	TIDVINCODE            = 0x27,                /**< 汽车VIN码*/
	TIDEEPHK            = 0x28,                /**< 港澳通行证*/
	TIDMARRY            = 0x29,                /**< 结婚证*/
	TIDRESIDENCE        = 0x2a,                /**< 户口本*/
	TIDSTAMP            = 0x2b,                /**< 验讫章*/
	TIDOPENACC            = 0x2c,                /**< 开户许可证*/
	TIDINDIACARD        = 0x2d,                /**< 印度身份证*/
	TIDSCRIDENCE        = 0x2e,                /**< 退票费凭证*/
	TIDLASTFLG            = 0x2f,                /**< 结束标志*/
	/*--TURI_NEWENGINE_STEP_XXX_CFG--*//*请勿删除或修改该标签*/
} TCARD_TYPE;

/**
 * @brief 获取字段索引
 */
typedef enum
{
	/*身份证*/
	NAME                    = 0,            /**< 姓名*/
	SEX                        = 1,            /**< 性别*/
	FOLK                    = 2,            /**< 民族*/
	BIRTHDAY                = 3,            /**< 出生日期*/
	ADDRESS                    = 4,            /**< 地址*/
	NUM                        = 5,            /**< 号码*/
	ISSUE                    = 6,            /**< 签发机关*/
	PERIOD                    = 7,            /**< 有效期限*/

	IDC_NAME                = 0,            /**< 姓名*/
	IDC_SEX                    = 1,            /**< 性别*/
	IDC_FOLK                = 2,            /**< 民族*/
	IDC_BIRTHDAY            = 3,            /**< 出生日期*/
	IDC_ADDRESS                = 4,            /**< 地址*/
	IDC_NUM                    = 5,            /**< 号码*/
	IDC_ISSUE                = 6,            /**< 签发机关*/
	IDC_PERIOD                = 7,            /**< 有效期限*/
	IDC_PASS_NUM            = 69,            /**< 通行证号码*/

	/*车牌*/
	LPR_NUM                    = 8,            /**< 车牌号码*/
	LPR_PLATECOLOR            = 9,            /**< 车牌颜色*/

	/*行驶证*/
	DP_PLATENO                = 10,            /**< 号牌号码*/
	DP_TYPE                    = 11,            /**< 车辆类型*/
	DP_OWNER                = 12,            /**< 所有人*/
	DP_ADDRESS                = 13,            /**< 住址*/
	DP_USECHARACTER            = 14,            /**< 使用性质*/
	DP_MODEL                = 15,            /**< 品牌号码*/
	DP_VIN                    = 16,            /**< 车辆识别代号*/
	DP_ENGINENO                = 17,            /**< 发动机号码*/
	DP_REGISTER_DATE        = 18,            /**< 注册日期*/
	DP_ISSUE_DATE            = 19,            /**< 发证日期*/

	/*驾驶证*/
	DL_NUM                    = 20,            /**< 号码*/
	DL_NAME                    = 21,            /**< 姓名*/
	DL_SEX                    = 22,            /**< 性别*/
	DL_COUNTRY                = 23,            /**< 国籍*/
	DL_ADDRESS                = 24,            /**< 地址*/
	DL_BIRTHDAY                = 25,            /**< 出生日期*/
	DL_ISSUE_DATE            = 26,            /**< 初次领证日期*/
	DL_CLASS                = 27,            /**< 准驾车型*/
	DL_VALIDFROM            = 28,            /**< 有效起始日期*/
	DL_VALIDFOR                = 29,            /**< 有效期限*/

	/*火车票*/
	TIC_START                = 30,            /**< 起始站*/
	TIC_NUM                    = 31,            /**< 车次*/
	TIC_END                    = 32,            /**< 终点站*/
	TIC_TIME                = 33,            /**< 发车时间*/
	TIC_SEAT                = 34,            /**< 座位号*/
	TIC_NAME                = 35,            /**< 姓名*/
	TIC_PRICE                = 61,            /**< 价格*/
	TIC_SEATCLASS            = 62,            /**< 座位类型*/
	TIC_CARDNUM                = 63,            /**< 身份证号码*/

	/*银行卡字段*/
	TBANK_NUM                = 36,            /**< 获取银行卡号*/
	TBANK_NAME                = 37,            /**< 获取银行卡开户行*/
	TBANK_ORGCODE            = 38,            /**< 获取银行机构代码*/
	TBANK_CLASS                = 39,            /**< 获取卡种*/
	TBANK_CARD_NAME            = 40,            /**< 获取卡名*/
	TBANK_NUM_REGION        = 41,            /**< 获取银行卡号行区域*/
	TBANK_NUM_CHECKSTATUS    = 42,            /**< 获取银行卡号校验状态（该状态标记仅在非扫描识别模式下有效）*/
	TBANK_IMG_STREAM        = 43,            /**< 银行卡号码区域图字节流*/
	TBANK_LENTH_IMGSTREAM    = 44,            /**< 卡号区域图片字节流长度*/

	/*社保卡字段*/
	SSC_NAME                = 45,            /**< 姓名*/
	SSC_NUM                    = 46,            /**< 身份证号*/
	SSC_SHORTNUM            = 47,            /**< 卡号*/
	SSC_PERIOD                = 48,            /**< 有效期限*/
	SSC_BANKNUM                = 49,            /**< 银行卡号*/

	/*护照字段*/
	PAS_PASNO                = 50,            /**< 护照号*/
	PAS_NAME                = 51,            /**< 姓名*/
	PAS_SEX                    = 52,            /**< 性别*/
	PAS_IDCARDNUM            = 53,            /**< 身份证号码*/
	PAS_BIRTH                = 54,            /**< 生日*/
	PAS_PLACE_BIRTH            = 55,            /**< 出生地址*/
	PAS_DATE_ISSUE            = 56,            /**< 签发日期*/
	PAS_DATE_EXPIRY            = 57,            /**< 有效日期*/
	PAS_PLACE_ISSUE            = 58,            /**< 签发地址*/
	PAS_NATION_NAME            = 59,            /**< 国籍和姓名监督码*/
	PAS_MACHINE_RCODE        = 60,            /**< 护照号+国籍代码+生日代码（YYMMDD）+性别（M/F）+护照有效期（YYMMDD）+校验码 监督码*/

	/*钻孔柱状图*/
	DRILL_NAME                = 64,            /**< 名称*/
	DRILL_NUM                = 65,            /**< 编号*/
	DRILL_DATE                = 66,            /**< 勘探日期*/
	DRILL_FIGURE            = 67,            /**< */
	DRILL_FIGURE_SUM        = 68,            /**< */

	/*营业执照*/
	BLIC_CODE                = 72,            /**< 统一社会信用代码*/
	BLIC_NAME                = 73,            /**< 名称*/
	BLIC_TYPE                = 74,            /**< 类型*/
	BLIC_ADDR                = 75,            /**< 住所*/
	BLIC_PERSON                = 76,            /**< 法定代表人*/
	BLIC_CAPTIAL            = 77,            /**< 注册资本*/
	BLIC_DATE                = 78,            /**< 成立日期*/
	BLIC_PERIOD                = 79,            /**< 营业期限*/
	BLIC_ISSUE                = 80,            /**< 发证日期*/
	BLIC_SERIAL                = 81,            /**< 证照编号*/
	BLIC_SCOPE                = 82,            /**< 经营范围*/
	BLIC_AUTH                = 83,            /**< 登记机关*/

	/*增值税发票*/
	INV_CODE                = 84,            /**< 发票代号*/
	INV_NUM                    = 85,            /**< 发票号码*/
	INV_DATE                = 86,            /**< 开票日期*/
	INV_PASSWORD            = 87,            /**< 密码区*/
	INV_BUY                    = 88,            /**< 购方企业名称*/
	INV_BUYCODE                = 89,            /**< 购方纳税号*/
	INV_SALE                = 90,            /**< 销方企业名称*/
	INV_SALECODE            = 91,            /**< 销方纳税号*/
	INV_PRODUCT                = 92,            /**< 货物或应税劳务名称*/
	INV_PRICE_TAX            = 93,            /**< 价税合计*/
	INV_PRICE                = 94,            /**< 合计金额*/
	INV_TAX                    = 95,            /**< 合计税额*/
	INV_MARK                = 96,            /**< 备注*/
	INV_TAXRATE                = 97,            /**< 税率*/

	DOC_TEXT                = 100,            /**< 文档文本*/
	RMB_NUM                    = 101,            /**< 人民币冠字号*/

	VIN_CODE                = 105,            /**< 发动机识别代号*/

	/*港澳通行证*/
	EEP_NUM                    = 109,            /**< 证号*/
	EEP_NAME                = 110,            /**< 姓名*/
	EEP_BIRTH                = 111,            /**< 出生日期*/
	EEP_SEX                    = 112,            /**< 性别*/
	EEP_PERIOD                = 113,            /**< 有效期限*/
	EEP_PLACE_ISSUE            = 114,            /**< 签发地点*/
	EEP_MACHINE_RCODE        = 115,            /**< 机读码*/

	/*结婚证*/
	MAR_OWNER                = 119,            /**< 持证人*/
	MAR_PERIOD                = 120,            /**< 登记日期*/
	MAR_NUM                    = 121,            /**< 结婚证字号*/
	MAR_MAN                    = 122,            /**< 男方姓名*/
	MAR_MAN_BIRTH            = 123,            /**< 男方生日*/
	MAR_MAN_NUM                = 124,            /**< 男方证件号*/
	MAR_WIFE                = 125,            /**< 女方姓名*/
	MAR_WIFE_BIRTH            = 126,            /**< 女方生日*/
	MAR_WIFE_NUM            = 127,            /**< 女方证件号*/

	/*户口本*/
	RES_TYPE                = 131,            /**< 户别*/
	RES_HOLDER                = 132,            /**< 户主姓名*/
	RES_NUM                    = 133,            /**< 户号*/
	RES_ADDRESS                = 134,            /**< 住址*/
	RES_PERIOD                = 135,            /**< 签发日期*/
	RES_NAME                = 136,            /**< 姓名*/
	RES_RELATIONSHIP        = 137,            /**< 户主关系*/
	RES_USED_NAME            = 138,            /**< 曾用名*/
	RES_SEX                    = 139,            /**< 性别*/
	RES_PLACE_BIRTH            = 140,            /**< 出生地*/
	RES_FLOK                = 141,            /**< 民族*/
	RES_COUNTRY                = 142,            /**< 籍贯*/
	RES_BIRTH                = 143,            /**< 出生日期*/
	RES_OTHER_ADDR            = 144,            /**< 其他住址*/
	RES_RELIGION            = 145,            /**< 宗教信仰*/
	RES_CARDNUM                = 146,            /**< 身份证号码*/
	RES_HEIGHT                = 147,            /**< 身高*/
	RES_BLOOD                = 148,            /**< 血型*/
	RES_EDUCATION            = 149,            /**< 文化程度*/
	RES_MARRY                = 150,            /**< 婚姻状况*/
	RES_MILITARY            = 151,            /**< 兵役状况*/
	RES_SERVICE_ADDR        = 152,            /**< 服务处所*/
	RES_OCCUPATION            = 153,            /**< 职业*/

	YQZ_STRING                = 157,            /**< 验证章日期串*/

	/*开户许可证*/
	LFOA_PERMITNUM            = 161,            /**< 核准号*/
	LFOA_SERIALNUM            = 162,            /**< 编号*/
	LFOA_COMPANY            = 163,            /**< 公司名称*/
	LFOA_LEGALPERSON        = 164,            /**< 法定代表人*/
	LFOA_BANKNAME            = 165,            /**< 开户银行*/
	LFOA_ACCOUNTNUM            = 166,            /**< 账号*/

	/*印度身份证*/
	IND_NAME                = 170,            /**< 姓名*/
	IND_DOB                    = 171,            /**< 生日*/
	IND_SEX                    = 172,            /**< 性别*/
	IND_MOBILE                = 173,            /**< 电话*/
	IND_NUM                    = 174,            /**< 卡号*/
	IND_ADDRESS                = 175,            /**< 地址*/

	/*退票报销凭证*/
	SCR_NAME                = 179,            /**< 铁路局*/
	SCR_RMB                    = 180,            /**< 人民币大写*/
	SCR_RMBL                = 181,            /**< 人民币小写*/
	SCR_NUM                    = 182,            /**< 收据号码*/
	SCR_TITLE                = 183,            /**< 退费票报销凭证*/

	TR_FULL_IMAGE            = 209,            /**< 存放各个栏目提取后的结果*/

	TMAX                    = 212,            /**< 最大值*/
	/*--TURI_NEWENGINE_STEP_XXX_DECLARE--*//*请勿删除或修改该标签*/
}TFIELDID;

typedef enum
{
	TIDC_NORMAL_MODE =0,
	TIDC_SCAN_MODE =1,
}TIDC_REC_MODE;
/**
 * @brief 获取银行卡字段索引
 */
typedef enum
{
	T_GET_BANK_NUM            = 0x01,            /**< 获取银行卡号*/
	T_GET_BANK_NAME            = 0x02,            /**< 获取银行卡开户行*/
	T_GET_BANK_ORGCODE        = 0x03,            /**< 获取银行机构代码*/
	T_GET_BANK_CLASS        = 0x04,            /**< 获取卡种*/
	T_GET_CARD_NAME            = 0x05,            /**< 获取卡名*/
	T_GET_NUM_REGION        = 0x06,            /**< 获取银行卡号行区域*/
	T_GET_NUM_CHECKSTATUS    = 0x07,            /**< 获取银行卡号校验状态（该状态标记仅在非扫描识别模式下有效）*/
	T_GET_IMAGE_STREAM        = 0x08,            /**< 获取图像流*/
	T_GET_LENTH_IMGSTREAM    = 0x09,            /**< 获取图片流的长度*/
}TGETBANKINFOID;

/**
 * @brief 银行卡号识别结果是否满足LUTI校验模式(该校验模式仅在非扫描模式下有效)
 */
typedef enum
{
	TBANK_STATUS_FAIL        = 0,    /**< 当前卡号结果不满足LUTI校验*/
	TBANK_STATUS_CHECK        = 1,    /**< 当前卡号结果满足LUTI校验*/
}TBANK_CARDNUM_STATUS;

/**
 * @brief 原图像方向索引，返回标识
 */
typedef enum
{
	IMG_DIRECT_UP            = 0,    /**< 原图像为正向输入*/
	IMG_DIRECT_RIGHT        = 1,    /**< 原图像输入前，被90度翻转*/
	IMG_DIRECT_BOTTOM        = 2,    /**< 原图像输入前，被180度翻转*/
	IMG_DIRECT_LEFT            = 3,    /**< 原图像输入前，被-90度翻转*/
}TDIRECT_TYPE;

/**
 * @brief 车牌颜色索引
 */
typedef enum
{
	BLUE_PLATE                = 1,            /**< 蓝色*/
	YELLOW_PLATE            = 2,            /**< 黄色*/
	WHITE_PLATE                = 4,            /**< 白色*/
	BLACK_PLATE                = 8,            /**< 黑色*/
	GREEN_PLATE                = 16            /**< 绿色*/
}LPR_COLOR;

/**
 * @brief 车牌层级
 */
typedef enum enumPlateLayer
{
	SIG_LAYER        =    1,    /**< 单层*/
	MUL_LAYER        =    2    /**< 多层*/
}LPR_LAYER;


/************************************************************************\
 *                         配置文件解析使用的结构                         *
 \************************************************************************/
/**
 * @brief 参数选项
 */
typedef enum
{
	T_CFG_MODE_UNSET    =    0,    /**< 当前配置，不选中或不需要内部配置*/
	T_CFG_MODE_SET        =    1,    /**< 当前配置，选中或需要内部配置*/
}TCfgOption;

/**
 * @brief    配置文件解析结构体
 * @warning 当前结构体引用到指针指向的内存，在引用完成后会被free释放！
 *            请勿在外部重复释放内存！！！
 */
typedef struct
{
	/// 身份标识信息，用于区分当前结构体指针
	char        signVal[LENTH_VERSION_MAX];
	/// 仅识别身份证号码
	TCfgOption    cfgOnlyIdNum;
	/// 配置头像截取功能是否开启
	TCfgOption    cfgGetHeadImage;
	/// 配置MFC中，LOGO的显示
	TCfgOption    cfgMfcComponyLogo;

	/// 数据流的加载方式
	TCfgOption    cfgStreamLoad;
	/// 授权文件路径
	char        licenseFilePath[MAX_LENGTH_PATH];
	/// 模型数据路径
	char        mdlFilePath[MAX_LENGTH_PATH];
	/// 授权文件流指针
	char        *licenseStream;
	/// 模型数据流指针
	char        *mdlStream;
}TCFGINFO;

/**
 * @brief 获取坐标的位置
 */
typedef enum
{
	POS_LEFT_TOP                = 0,        /**< 左上点*/
	POS_RIGHT_TOP                = 1,        /**< 右上点*/
	POS_LEFT_BOTTOM                = 2,        /**< 左下点*/
	POS_RIGHT_BOTTOM            = 3,        /**< 右下点*/
}POINT_POS;

/**
 * @brief 用于获取指定栏目，指定坐标位置的坐标值
 */
typedef struct
{
	/* input */
	/// 需要获取哪个坐标点位置
	POINT_POS    pos;
	/// 指定栏目ID
	TFIELDID    field;

	/* output */
	/// pos指定位置的X坐标
	Gint        posPointX;
	/// pos指定位置的Y坐标
	Gint        posPointY;
}PosiTion;


/************************************************************************\
 *                            参数选项及设置                              *
 \************************************************************************/
/**
 * @brief 参数设置选项
 */
typedef enum
{
	T_ONLY_CARD_NUM                = 0x0001,    /**< 设置是否只识别卡号*/
	T_SET_HEADIMG                = 0x0002,    /**< 设置是否要截取人头像信息*/
	T_SET_LOGPATH                = 0x0004,    /**< 设置保存log保存文件位置*/
	T_SET_VERSION                = 0x0005,    /**< 获取版本比较情况*/
	T_SET_HEADIMGBUFMODE        = 0x0006,    /**< 设置人头像模式 0= 原始形式(便于android ios直接加载)   1=BASE64加密形式(便于sdk网络传输)*/
	T_SET_NDCORRECTION            = 0x0007,    /**< 设置是否进行畸形矫正功能*/

	T_SET_RECMODE                = 0x0008,    /**< 设置引擎识别模式，仅支持身份证和银行卡*/
	T_SET_AREA_LEFT                = 0x0009,    /**< 设置扫描模式下识别引擎区域左边坐标，仅支持身份证和银行卡*/
	T_SET_AREA_TOP                = 0x0010,    /**< 设置扫描模式下识别引擎区域顶点坐标，仅支持身份证和银行卡*/
	T_SET_AREA_WIDTH            = 0x0011,    /**< 设置扫描模式下识别引擎区域宽度，仅支持身份证和银行卡*/
	T_SET_AREA_HEIGHT            = 0x0012,    /**< 设置扫描模式下识别引擎区域高度，仅支持身份证和银行卡*/

	T_SET_BANK_LINE_STREAM        = 0x0013,    /**< 设置是否以图片流的方式导出银行卡号行*/

	T_SET_SSC_AREA_NAME            = 0x0014,    /**< 设置社保卡识别省份*/
	T_SET_ROTATE_180            = 0x0015,    /**< GET参数，用于获取银行卡输入图片是否为倒置*/
	T_SET_CHECKCOPY_MODE        = 0x0016,    /**< 设置复印件拒绝识别模式*/

	T_SET_PER_CALL_ACCOUNT        = 0x0017,    /**< 设置客户端+服务的按次收费模式下，授权用户名*/
	T_SET_PER_CALL_PASSWORD        = 0x0018,    /**< 设置客户端+服务的按次收费模式下，授权密码*/
	T_SET_PER_CALL_SERVERURL    = 0x0019,    /**< 设置客户端+服务的按次收费模式下，服务接口*/
	T_SET_PER_CALL_TIMEOUT        = 0x0020,    /**< 设置客户端+服务的按次收费模式下，超时时长*/

	T_SET_SAVE_PATH_CSHARP        = 0x0021,    /**< C#下，验讫章设置图片保存路径*/
	T_SET_CARDREGIONIMG            = 0x0022,    /**< 设置JSON流身份证区域截图是否导出 0 = 不做导出， 1 = 导出 图片流的模式与头像一致，参见 @ref T_SET_HEADIMGBUFMODE */
	T_SET_EVALUE_QUALITY        = 0x0023,    /**< 当前模式会进行图片质量的判断*/

	T_GET_ANDROID_PACKAGE        = 0x0024,    /**< 获取绑定的安卓包名*/
	T_GET_IOS_BUNDLE_ID            = 0x0025,    /**< 获取绑定的IOS包名*/
}
		TPARAM;

/**
 * @brief 社保卡地域设置
 */
typedef enum
{
	ARE_FUJIAN                    = 0x01,        /**< 福建*/
	ARE_SHANGHAI                = 0x01,        /**< 上海*/
}
		SSCAREANAME;


/************************************************************************\
 *                                 其他                                   *
 \************************************************************************/
/**
 * @brief 回调函数
 */
extern f_progress SendToMainMsg;


#endif
