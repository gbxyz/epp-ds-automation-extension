---
title: DS Automation Status Extension for the Extensible Provisioning Protocol (EPP)
docname: DOC_NAME
stand_alone: true
ipr: trust200902
area: Operations
wg: REGEXT Working Group
kw: Internet-Draft
cat: std
pi:
    - toc
    - sortrefs
    - symrefs

author:
    - ins: G. Brown
      name: Gavin Brown
      org: ICANN
      email: gavin.brown@icann.org

normative:
    I-D.ietf-dnsop-ds-automation:
    RFC2199:
    RFC5730:
    RFC5731:
    RFC5910:
    RFC7344:
    RFC8078:
    RFC9364:
    RFC9615:
    STD95:
    BCP14:

informative:
    RFC9499:

--- abstract

This document specifies an extension to the Domain Mapping for the Extensible Provisioning Protocol (EPP) {{RFC5730}} {{RFC5731}} which allows EPP clients to enable and disable automatic DNSSEC maintenance {{RFC7344}} {{RFC8078}} {{RFC9615}} carried out by the server. It also describes how the maintenance state of a domain can be included in RDAP ({{STD95}}, {{RFC9083}}) responses.

--- middle

# Introduction

{{RFC7344}}, {{RFC8078}}, and {{RFC9615}} automate DNSSEC {{RFC9364}} delegation trust maintenance by having the child publish Child DS (CDS) and/or Child DNSKEY (CDNSKEY) records which indicate the delegation's desired DNSSEC parameters ("DS automation"). {{I-D.ietf-dnsop-ds-automation}} provides operational recommendations for parent operators wishing to deploy these protocols.

Section 6.1 of {{I-D.ietf-dnsop-ds-automation}} states that domain name registries (see Section 9 of {{RFC9499}}) **MUST NOT** suspend DS automation solely on the basis of the presence of the `serverUpdateProhibited` {{RFC5731}} status code. This status code causes any request to modify the domain name (including its DS record(s) {{RFC5910}}) to be rejected by the EPP server.

The most common use of the `serverUpdateProhibited` status is as part of a "registry lock", a security measure designed to mitigate the risk of a compromised customer account at the sponsoring registrar (or of a compromised or malicious registrar). For domains which have a registry lock, it is not always the case that the registrant of the domain will want DS automation to take place.

This document specifies an extension to the Domain Mapping for the Extensible Provisioning Protocol (EPP) {{RFC5730}} {{RFC5731}} which allows the sponsoring client of a domain object to specify whether or not DS automation should be carried out by the server.

It also describes how the automation state of domain objects should be represented in RDAP ({{STD95}}) responses.

## 1.1. Conventions Used in This Document

(Standard boilerplate about BCP14 keywords, XML syntax, etc)

# EPP Extension Elements

This specification adds a new element, `<ds-automation:automation>`, to the domain name mapping. This element has a single boolean "`enabled`" attribute, whose default value is "`true`" or "`1`".

* If the value of the "`enabled`" attribute is "`true`" or "`1`", then the server **MAY** perform DS automation for the domain.

* If the value of the "`enabled`" attribute is "`false`" or "`0`", then the server **MUST NOT** perform DS automation for the domain.

# EPP Command Mapping

## EPP Query Commands

### EPP `<info>` Command

This extension does not add any elements to the EPP `<info>` command described in the EPP domain mapping {{RFC5731}}.  However, additional elements are defined for the `<info>` response.

When an `<info>` command has been processed successfully, the EPP `<resData>` element **MUST** contain child elements as described in the EPP domain mapping {{RFC5731}}.  In addition, the EPP `<extension>` element **SHOULD** contain a child `<ds-automation:infData>` element that identifies the extension namespace if the domain object has data associated with this extension and based on server policy.  The `<ds-automation:infData>` element MUST contain a single `<ds-automation:automation>` which represents the current configuration status for the domain.

Example domain `<info>` response:

#exec sed 's/^/    S: /' examples/info-response.xml

## EPP Transform Commands

### EPP `<create>` Command

This extension defines additional elements for the EPP `<create>` command described in the EPP domain mapping {{RFC5731}}.  No additional elements are defined for the EPP `<create>` response.

The EPP `<create>` command provides a transform operation that allows a client to create a domain object. In addition to the EPP command elements described in the EPP domain mapping {{RFC5731}}, the command **MUST** contain an `<extension>` element, and the `<extension>` element **MUST** contain a child `<ds-automation:create>` element that identifies the extension namespace if the client wants to associate data defined in this extension to the domain object.  The `<ds-automation:create>` element **MUST** contain a single `<ds-automation:automation>` which represents the desired configuration status for the domain.

Example domain `<create>` command:

#exec sed 's/^/    C: /' examples/create-command.xml

### EPP `<update>` Command

This extension defines additional elements for the EPP `<update>` command described in the EPP domain mapping {{RFC5731}}.  No additional elements are defined for the EPP `<update>` response.

The EPP `<update>` command provides a transform operation that allows a client to modify the attributes of a domain object. In addition to the EPP command elements described in the EPP domain mapping, the command **MUST** contain an `<extension>` element, and the `<extension>` element **MUST** contain a child `<ds-automation:update>` element that identifies the extension namespace if the client wants to update the domain object with data defined in this extension. The `<ds-automation:update>` element **MUST** contain a single `<ds-automation:automation>` which represents the desired configuration status for the domain.

Example domain `<update>` command:

#exec sed 's/^/    C: /' examples/update-command.xml

# RDAP Status Mapping

Operators of EPP servers who also operate an RDAP server can include an entry in the "`status`" property of domain responses to allow interested parties to determine whether DS automation is enabled or disabled for a given domain name.

* Domains for which DS automation is enabled (ie the value of the "`enabled`" property is "`true`" or "`1`") **MUST** have the "`DS automation enabled`" value in their "`status`" property.  
* Domains for which DS automation is disabled (ie the value of the "`enabled`" property is "`false`" or "`0`") **MUST** have the "`DS automation disabled`" value in their "`status`" property.

These two values **MUST NOT** both be present at the same time.

# Formal Syntax (EPP)

#exec sed 's/^/    /' schema.xsd

# IANA Considerations

(registration in XML and EPP Extension Registry)

(registration of RDAP status values)

# Security Considerations

The mapping extensions described in this document do not provide any security services beyond those described by EPP {{RFC5730}}, the EPP domain name mapping {{RFC5731}}, and protocol layers used by EPP. The security considerations described in these other specifications apply to this specification as well.

As with other domain object transforms, the EPP transform operations described in this document **MUST** be restricted to the sponsoring client as authenticated using the mechanisms described in Sections 2.9.1.1 and 7 of RFC 5730 {{RFC5730}}. Any attempt to perform a transform operation on a domain object by any client other than the sponsoring client **MUST** be rejected with an appropriate EPP authorization error.

The provisioning service described in this document involves the exchange of information that can have an operational impact on the DNS. A trust relationship **MUST** exist between the EPP client and server using a strong authentication mechanism.

# Operational Considerations

Server operators **MUST** obey the value for the "`enabled`" property, irrespective of the presence (or absence) of EPP status codes such as `serverUpdateProhibited`.

When the "`enabled`" property is "`false`" or "`0`", the EPP client **MAY** perform DS automation itself, and submit any necessary changes to the DNSSEC configuration of the domain using an `<update>` command extended by {{RFC5910}}.

When the "`enabled`" property is "`true`" or "`1`", the EPP client **SHOULD NOT** perform DS automation, for the reasons outlined in Section 7.2.3 of {{I-D.ietf-dnsop-ds-automation}}.

It is impractical for EPP clients with large portfolios of domain names to submit `<update>` commands to enable or disable DS automation for all domains under their sponsorship. Therefore, server operators **SHOULD** provide an out-of-band method for client operators to enable or disable DS automation for their entire portfolio of domain names.
