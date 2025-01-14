#include <core.p4>
#define V1MODEL_VERSION 20180101
#include <v1model.p4>

typedef bit<48> EthernetAddress;
enum bit<16> ether_type_t {
    TPID = 0x8100,
    IPV4 = 0x800,
    IPV6 = 0x86dd
}

header ethernet_t {
    EthernetAddress dstAddr;
    EthernetAddress srcAddr;
    bit<16>         etherType;
}

header vlan_tag_h {
    bit<3>       pcp;
    bit<1>       cfi;
    bit<12>      vid;
    ether_type_t ether_type;
}

struct headers_t {
    ethernet_t    ethernet;
    vlan_tag_h[2] vlan_tag;
}

struct main_metadata_t {
    bit<2>  depth;
    bit<16> ethType;
}

parser parserImpl(packet_in pkt, out headers_t hdrs, inout main_metadata_t meta, inout standard_metadata_t stdmeta) {
    state start {
        meta.depth = 2 - 1;
        pkt.extract(hdrs.ethernet);
        transition select(hdrs.ethernet.etherType) {
            ether_type_t.TPID: parse_vlan_tag;
            default: accept;
        }
    }
    state parse_vlan_tag {
        pkt.extract(hdrs.vlan_tag.next);
        meta.depth = meta.depth - 1;
        transition select(hdrs.vlan_tag.last.ether_type) {
            ether_type_t.TPID: parse_vlan_tag;
            default: accept;
        }
    }
}

control verifyChecksum(inout headers_t hdr, inout main_metadata_t meta) {
    apply {
    }
}

control ingressImpl(inout headers_t hdrs, inout main_metadata_t meta, inout standard_metadata_t stdmeta) {
    action drop_packet() {
        mark_to_drop(stdmeta);
    }
    action execute() {
        meta.ethType = hdrs.vlan_tag[meta.depth - 1].ether_type;
        hdrs.vlan_tag[meta.depth - 1].ether_type = (ether_type_t)16w2;
        hdrs.vlan_tag[meta.depth].vid = (bit<12>)hdrs.vlan_tag[meta.depth].cfi;
        hdrs.vlan_tag[meta.depth].vid = hdrs.vlan_tag[meta.depth - 1].vid;
    }
    action execute_1() {
        drop_packet();
    }
    table stub {
        key = {
            hdrs.vlan_tag[meta.depth].vid: exact;
        }
        actions = {
            execute;
        }
        const default_action = execute;
        size = 1000000;
    }
    table stub1 {
        key = {
            hdrs.ethernet.etherType: exact;
        }
        actions = {
            execute_1;
        }
        const default_action = execute_1;
        size = 1000000;
    }
    apply {
        switch (hdrs.vlan_tag[meta.depth].vid) {
            12w1: {
                stub.apply();
            }
            12w2: {
                if (hdrs.vlan_tag[meta.depth].ether_type == hdrs.ethernet.etherType) {
                    stub1.apply();
                }
            }
        }
    }
}

control egressImpl(inout headers_t hdr, inout main_metadata_t meta, inout standard_metadata_t stdmeta) {
    apply {
    }
}

control updateChecksum(inout headers_t hdr, inout main_metadata_t meta) {
    apply {
    }
}

control deparserImpl(packet_out pkt, in headers_t hdr) {
    apply {
        pkt.emit(hdr.ethernet);
    }
}

V1Switch(parserImpl(), verifyChecksum(), ingressImpl(), egressImpl(), updateChecksum(), deparserImpl()) main;

