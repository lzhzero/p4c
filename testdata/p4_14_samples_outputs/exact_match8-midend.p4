#include <core.p4>
#define V1MODEL_VERSION 20200408
#include <v1model.p4>

header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<32> f3;
    bit<32> f4;
    bit<8>  b1;
    bit<8>  b2;
    bit<8>  b3;
    bit<8>  b4;
}

struct metadata {
}

struct headers {
    @name(".data") 
    data_t data;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract<data_t>(hdr.data);
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @noWarn("unused") @name(".NoAction") action NoAction_1() {
    }
    @name(".noop") action noop() {
    }
    @name(".setb1") action setb1(@name("val") bit<8> val) {
        hdr.data.b1 = val;
    }
    @name(".setb2") action setb2(@name("val") bit<8> val_4) {
        hdr.data.b2 = val_4;
    }
    @name(".setb3") action setb3(@name("val") bit<8> val_5) {
        hdr.data.b3 = val_5;
    }
    @name(".setb4") action setb4(@name("val") bit<8> val_6) {
        hdr.data.b4 = val_6;
    }
    @name(".setb12") action setb12(@name("v1") bit<8> v1, @name("v2") bit<8> v2) {
        hdr.data.b1 = v1;
        hdr.data.b2 = v2;
    }
    @name(".setb13") action setb13(@name("v1") bit<8> v1_6, @name("v2") bit<8> v2_6) {
        hdr.data.b1 = v1_6;
        hdr.data.b3 = v2_6;
    }
    @name(".setb14") action setb14(@name("v1") bit<8> v1_7, @name("v2") bit<8> v2_7) {
        hdr.data.b1 = v1_7;
        hdr.data.b4 = v2_7;
    }
    @name(".setb23") action setb23(@name("v1") bit<8> v1_8, @name("v2") bit<8> v2_8) {
        hdr.data.b2 = v1_8;
        hdr.data.b3 = v2_8;
    }
    @name(".setb24") action setb24(@name("v1") bit<8> v1_9, @name("v2") bit<8> v2_9) {
        hdr.data.b2 = v1_9;
        hdr.data.b4 = v2_9;
    }
    @name(".setb34") action setb34(@name("v1") bit<8> v1_10, @name("v2") bit<8> v2_10) {
        hdr.data.b3 = v1_10;
        hdr.data.b4 = v2_10;
    }
    @name(".test1") table test1_0 {
        actions = {
            noop();
            setb1();
            setb2();
            setb3();
            setb4();
            setb12();
            setb13();
            setb14();
            setb23();
            setb24();
            setb34();
            @defaultonly NoAction_1();
        }
        key = {
            hdr.data.f1: exact @name("data.f1") ;
        }
        default_action = NoAction_1();
    }
    apply {
        test1_0.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<data_t>(hdr.data);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

