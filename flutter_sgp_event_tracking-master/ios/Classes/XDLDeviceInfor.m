//
//  XDLDeviceInfor.m
//  XDLogCollection
//
//  Created by coco.zhu on 2021/1/12.
//

#import "XDLDeviceInfor.h"
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>
// 下面是获取ip需要的头文件
#include <ifaddrs.h>
#include <sys/socket.h> // Per msqr
#import <sys/ioctl.h>
#include <net/if.h>
#import <arpa/inet.h>
 // 获取CPU信息所需要引入的头文件
#include <mach/mach.h>
@implementation XDLDeviceInfor

- (NSString *)getDeviceVersionInfo{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithFormat:@"%s", systemInfo.machine];
    
    return platform;
}
/**
 设备名称，比如iphone 5s ,iphone 6s
 */
- (NSString *)getDeviceName
{
    //官网 https://www.theiphonewiki.com/wiki/Models#iPhone
    NSString *phoneGeneration = [self getDeviceVersionInfo];
    NSString *name;
    NSDictionary *map = @{
        @"iPhone1,1" : @"iPhone 1",
        @"iPhone1,2" : @"iPhone 3G",
        @"iPhone2,1" : @"iPhone 3GS",
        @"iPhone3,1" : @"iPhone 4",
        @"iPhone3,2" : @"iPhone 4",
        @"iPhone3,3" : @"iPhone 4",
        @"iPhone4,1" : @"iPhone 4S",
        @"iPhone5,1" : @"iPhone 5",
        @"iPhone5,2" : @"iPhone 5",
        @"iPhone5,3" : @"iPhone 5c",
        @"iPhone5,4" : @"iPhone 5c",
        @"iPhone6,1" : @"iPhone 5s",
        @"iPhone6,2" : @"iPhone 5s",
        @"iPhone7,1" : @"iPhone 6 Plus",
        @"iPhone7,2" : @"iPhone 6",
        @"iPhone8,1" : @"iPhone 6s",
        @"iPhone8,2" : @"iPhone 6s Plus",
        @"iPhone8,4" : @"iPhone SE 1",
        @"iPhone9,1" : @"iPhone 7",
        @"iPhone9,2" : @"iPhone 7 Plus",
        @"iPhone9,3" : @"iPhone 7",
        @"iPhone9,4" : @"iPhone 7 Plus",
        @"iPhone10,1" : @"iPhone 8",
        @"iPhone10,2" : @"iPhone 8 Plus",
        @"iPhone10,3" : @"iPhone X",
        @"iPhone10,4" : @"iPhone 8",
        @"iPhone10,5" : @"iPhone 8 Plus",
        @"iPhone10,6" : @"iPhone X",
        @"iPhone11,2" : @"iPhone XS",
        @"iPhone11,4" : @"iPhone XS Max",
        @"iPhone11,6" : @"iPhone XS Max",
        @"iPhone11,8" : @"iPhone XR",
        @"iPhone12,1" : @"iPhone 11",
        @"iPhone12,3" : @"iPhone 11 Pro",
        @"iPhone12,5" : @"iPhone 11 Pro Max",
        @"iPhone12,8" : @"iPhone SE 2",
        @"iPhone13,1" : @"iPhone 12 mini",
        @"iPhone13,2" : @"iPhone 12",
        @"iPhone13,3" : @"iPhone 12 Pro",
        @"iPhone13,4" : @"iPhone 12 Pro Max",
    };
    name = map[phoneGeneration];
    return name ?: @"Unknow";
}
//CUP
- (NSString *)getDeviceCUPName
{
    NSString *phoneGeneration = [self getDeviceVersionInfo];
    NSString *name;
    NSDictionary *map = @{
        @"iPhone3,1" : @"A4",
        @"iPhone3,2" : @"A4",
        @"iPhone3,3" : @"A4",
        @"iPhone4,1" : @"A5",
        @"iPhone5,1" : @"A6",
        @"iPhone5,2" : @"A6",
        @"iPhone5,3" : @"A6",
        @"iPhone5,4" : @"A6",
        @"iPhone6,1" : @"A7",
        @"iPhone6,2" : @"A7",
        @"iPhone7,1" : @"A8",
        @"iPhone7,2" : @"A8",
        @"iPhone8,1" : @"A9",
        @"iPhone8,2" : @"A9",
        @"iPhone8,4" : @"A9",
        @"iPhone9,1" : @"A10",
        @"iPhone9,2" : @"A10",
        @"iPhone9,3" : @"A10",
        @"iPhone9,4" : @"A10",
        @"iPhone10,1" : @"A11",
        @"iPhone10,2" : @"A11",
        @"iPhone10,3" : @"A11",
        @"iPhone10,4" : @"A11",
        @"iPhone10,5" : @"A11",
        @"iPhone10,6" : @"A11",
        @"iPhone11,2" : @"A12",
        @"iPhone11,4" : @"A12",
        @"iPhone11,6" : @"A12",
        @"iPhone11,8" : @"A12",
        @"iPhone12,1" : @"A13",
        @"iPhone12,3" : @"A13",
        @"iPhone12,5" : @"A13",
        @"iPhone12,8" : @"A13",
        @"iPhone13,1" : @"A14",
        @"iPhone13,2" : @"A14",
        @"iPhone13,3" : @"A14",
        @"iPhone13,4" : @"A14",
    };
    name = map[phoneGeneration];
    return name ?: @"";
}

// 获取ip
- (NSString *)getIPAddresses {
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE = 4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString  stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString *deviceIP = @"";
    
    for (int i=0; i < ips.count; i++) {
        if (ips.count > 0) {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    return deviceIP;
}

///app使用cup
- (double)getAppCPUUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < (int)thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}
 
///CPU使用情况
- (float)getCPUUsage {
    float cpu = 0;
    NSArray *cpus = [self getPerCPUUsage];
    if (cpus.count == 0) return -1;
    for (NSNumber *n in cpus) {
        cpu += n.floatValue;
    }
    return cpu;
}

- (NSArray *)getPerCPUUsage {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if (_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}

#pragma mark -----Memory
- (int64_t)getMemoryTotal {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem / 1000;
}

- (int64_t)getMemoryUsed {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return page_size * (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) / 1000;
}

- (int64_t)getMemoryFree {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size / 1000;
}

- (int64_t)memoryActive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}

- (float)getAppUsedMemory {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (kernelReturn == KERN_SUCCESS) {
        int64_t memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        return memoryUsageInByte / 1024.0;
    } else {
        return -1;
    }
}


#pragma mark -----Disk
//获取app大小
- (int64_t)getAppSize {
    unsigned long long documentSize   =  [self xdl_getSizeOfFolder:[self xdl_getDocumentPath]];
    unsigned long long librarySize   =  [self xdl_getSizeOfFolder:[self xdl_getLibraryPath]];
    unsigned long long cacheSize =  [self xdl_getSizeOfFolder:[self xdl_getCachePath]];
    
    unsigned long long total = documentSize + librarySize + cacheSize;
    
    return total / 1000;
}
//磁盘总空间
- (int64_t)getTotalDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space / 1024;
}
//未使用的磁盘大小
- (int64_t)getFreeDiskSpace {
    
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space / 1024;
}
//已经使用的磁盘大小
- (int64_t)getUsedDiskSpace {
    int64_t totalDisk = [self getTotalDiskSpace];
    int64_t freeDisk = [self getFreeDiskSpace];
    if (totalDisk < 0 || freeDisk < 0) return -1;
    int64_t usedDisk = totalDisk - freeDisk;
    if (usedDisk < 0) usedDisk = -1;
    return usedDisk / 1024;
}

- (NSString *)xdl_getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}

- (NSString *)xdl_getLibraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}

- (NSString *)xdl_getCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}

-(unsigned long long)xdl_getSizeOfFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}

@end
