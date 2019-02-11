#!/usr/local/bin python
# coding=utf-8

import optparse, sys, string
from pynvml import *

class OptionClass:
    def __init__(self):
        self.id = None
        self.properties = None
        self.number = None
        self.summary = None
        self.avgGpuUtil = None
        self.helpProperties = None
        self.parser = None

    def parse(self):
        option_list = [
            optparse.make_option("-i", "--id",
                        action="store", type="string", dest="id",
                        help="Specific GPU unit id"),
            optparse.make_option("-p", "--properties",
                        action="store", type="string", dest="properties",
                        help="Query GPU properties"),
            optparse.make_option("--number",
                                 action="store_true", dest="number", help="Number of GPUs"),
            optparse.make_option("--summary",
                                 action="store_true", dest="summary", help="Summary list GPUs"),
            optparse.make_option("--avg-gpu-util",
                                 action="store_true", dest="avgGpuUtil", help="Average GPU utilization"),
            optparse.make_option("--help-properties",
                                 action="store_true", dest="helpProperties", help="Help properties of GPUs"),
        ]

        self.parser = optparse.OptionParser(option_list=option_list)
        (options, args) = self.parser.parse_args()

        if options.id is not None:
            self.id = int(options.id)
        if options.properties is not None:
            self.properties = options.properties
        if options.number is not None:
            self.number = options.number
        if options.summary is not None:
            self.summary = options.summary
        if options.avgGpuUtil is not None:
            self.avgGpuUtil = options.avgGpuUtil
        if options.helpProperties is not None:
            self.helpProperties = options.helpProperties

    def printHelpProperties(self):
        print("--properties=utilization.gpu", "Percent of executing on the GPU")
        print("--properties=memory.used", "Percent of used memory on the GPU")

    def validate(self):
        if self.helpProperties:
            self.printHelpProperties()
            sys.exit(0)

        if self.number or self.summary or self.avgGpuUtil:
            pass
            return

        if self.id is None or self.properties is None:
            self.parser.print_help()
            sys.exit(1)

class NvmlClass:
    def __init__(self):
        nvmlInit()

    def __del__(self):
        nvmlShutdown()

    def getDeviceNumber(self):
        deviceCount = nvmlDeviceGetCount()
        return deviceCount

    def getDeviceSummary(self):
        summaryList = []
        deviceCount = nvmlDeviceGetCount()
        for i in range(deviceCount):
            handle = nvmlDeviceGetHandleByIndex(i)
            name = nvmlDeviceGetName(handle)
            uuid = nvmlDeviceGetUUID(handle)
            info = {"id":i, "name":name, "uuid": uuid}
            summaryList.append(info)
        return summaryList

    def getDeviceUtilizationGPU(self, id):
        handle = nvmlDeviceGetHandleByIndex(int(id))
        util = nvmlDeviceGetUtilizationRates(handle)
        return int(util.gpu)

    def getDeviceUtilizationGPUAvg(self):
        deviceCount = nvmlDeviceGetCount()
        util_gpu = 0.0
        for i in range(deviceCount):
            handle = nvmlDeviceGetHandleByIndex(i)
            util = nvmlDeviceGetUtilizationRates(handle)
            util_gpu += util.gpu

        return int(util_gpu / deviceCount)

    def getDeviceMemoryUsed(self, id):
        handle = nvmlDeviceGetHandleByIndex(int(id))
        mem_info = nvmlDeviceGetMemoryInfo(handle)
        return int(float(mem_info.used) / float(mem_info.total) * 100)

def main():
    option = OptionClass()
    option.parse()
    option.validate()

    nvml = NvmlClass()
    if option.number:
        deviceCount = nvml.getDeviceNumber()
        print("GPU number:%d" % deviceCount)
    elif option.summary:
        for summary in nvml.getDeviceSummary():
            print("GPU %d: %s (UUID: %s)") % \
                (summary['id'], summary['name'], summary['uuid'])
    elif option.avgGpuUtil:
        print("GPU avg util:%d" % nvml.getDeviceUtilizationGPUAvg())
    elif option.properties == "utilization.gpu":
        print("GPU %d util:%d") % (option.id, nvml.getDeviceUtilizationGPU(option.id))
    elif option.properties == "memory.used":
        print("GPU %d mem used:%d") % (option.id, nvml.getDeviceMemoryUsed(option.id))
    else:
        print("Invalid properties:", option.properties)
        option.printHelpProperties()
        sys.exit(1)

if __name__ == "__main__":
    main()
