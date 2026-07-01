---
title: |
  Delegation Maintenance Automation Status Extension for the Extensible
  Provisioning Protocol (EPP)
abbrev: EPP Delegation Maintenance Automation Extension
docname: DOC_NAME
stand_alone: true
ipr: trust200902
area: Operations
stream: IETF
wg: REGEXT Working Group
kw: Internet-Draft
cat: std
pi: [toc, sortrefs, symrefs, comments]
author:
  name: Gavin Brown
  org: ICANN
  email: gavin.brown@icann.org

normative:
  I-D.ietf-dnsop-ds-automation:
  RFC3688:
  RFC5730:
  RFC5731:
  RFC7451:
  STD95:
  BCP14:

  XSD-DATATYPES:
    title: "XML Schema Part 2: Datatypes Second Edition"
    target: https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/
    author:
      - fullname: Paul V. Biron
      - fullname: Ashok Malhotra
    date: 2004-10
    refcontent: W3C Recommendation

  RDAP-JSON-VALUES:
    title: RDAP JSON Values
    target: https://www.iana.org/assignments/rdap-json-values/rdap-json-values.xhtml

  EPP-EXTENSIONS:
    title: Extensions for the Extensible Provisioning Protocol (EPP)
    target: https://www.iana.org/assignments/epp-extensions/epp-extensions.xhtml

informative:
  RFC5910:
  RFC7344:
  RFC7477:
  RFC8078:
  RFC9364:
  RFC9499:
  RFC9615:
  CENTR-REGISTRY-LOCK:
    title: Models of registry lock for top-level domain registries
    refcontent: CENTR
    target: https://centr.org/library/library/download/9799/6192/41.html
    date: 2020-08

--- abstract

This document specifies an extension to the Domain Mapping for the Extensible
Provisioning Protocol (EPP) which allows EPP clients to enable and disable
automatic delegation maintenance carried out by the server. It also describes
how the maintenance automation state of a domain can be included in RDAP
responses.

The source for this draft, and an issue tracker, may can be found at <eref
target="https://github.com/gbxyz/epp-ds-automation-extension"/>.

--- middle

# Introduction {#intro}

{{RFC7477}} automates the maintenance of other delegation information records,
typically `NS` records and any associated glue records (see Section 7 of
{{RFC9499}}) through the publication of `CSYNC` records in the child zone which
indicate the delegation's desired delegation information ("NS automation").

Similarly, {{RFC7344}}, {{RFC8078}}, and {{RFC9615}} automate DNSSEC
({{RFC9364}})  delegation trust maintenance by having the child publish Child DS
(`CDS`) and/or Child DNSKEY (`CDNSKEY`) records which indicate the delegation's
desired DNSSEC parameters ("DS automation").

{{I-D.ietf-dnsop-ds-automation}} provides operational recommendations for parent
operators wishing to deploy DS automation. Section 6.1 of
{{I-D.ietf-dnsop-ds-automation}} states that domain name registries (see
Section 9 of {{RFC9499}}) **MUST NOT** suspend DS automation  solely on the
basis of the presence of the `serverUpdateProhibited` status code (defined in
Section 2.3 of {{RFC5731}}). This status code causes any request to modify the
domain name (including DNSSEC information as per {{RFC5910}}) to be rejected by
the EPP server.

The most common use of the `serverUpdateProhibited` status is as part of a
"registry lock" (see {{CENTR-REGISTRY-LOCK}}), a security measure designed to
mitigate the risk of (a) a compromised customer account at the sponsoring
registrar (see Section 9 of {{RFC9499}}), or (b) a compromised or malicious
registrar. For domains which have a registry lock, it is not always the case
that the registrant of the domain will want either DS automation or NS
automation to take place.

This document specifies an extension to the Domain Mapping for the Extensible
Provisioning Protocol (EPP) {{RFC5730}} {{RFC5731}} which allows the sponsoring
client of a domain object to specify whether or not DS automation and/or NS
automation ("delegation automation") should be carried out by the server.

It also describes how the delegation automation state of domain objects should
be represented in RDAP ({{STD95}}) responses.

## Conventions Used in This Document

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{BCP14}} {{RFC2119}}
{{RFC8174}} when, and only when, they appear in all capitals, as shown here.

The term "delegation automation" refers to either or both of "DS automation" and
"NS automation", as described above. An EPP server may choose to implement
either or both of these protocols, in accordance with its own policy.

In this document's examples, "`C:`" represents lines sent by a protocol client
and "`S:`" represents lines returned by a protocol server. Indentation and
white space in these examples are provided only to illustrate element
relationships and are not required features of this protocol.

A protocol client that is authorized to manage an existing object is described
as a "sponsoring" client throughout this document.

XML is case sensitive. Unless stated otherwise, the XML specifications and
examples provided in this document MUST be interpreted in the character case
presented in order to develop a conforming implementation.

EPP uses XML namespaces to provide an extensible object management framework
and to identify schemas required for XML instance parsing and validation. These
namespaces and schema definitions are used to identify both the base protocol
schema and the schemas for managed objects.

The XML namespace prefixes used in these examples (such as the string
`automation` in `automation:ds-automation`) are solely for illustrative
purposes. A conforming implementation **MUST NOT** require the use of these or
any other specific namespace prefixes.

In accordance with Section 3.2.2.1 of XML Schema Part 2: Datatypes
{{XSD-DATATYPES}}, the allowable lexical representations for the `xs:boolean`
datatype are the strings "`0`" and "`false`" for the concept 'false' and the
strings "`1`" and "`true`" for the concept 'true'. Implementations **MUST**
support both styles of lexical representation.

# EPP Extension Elements

This specification adds two new elements, `<automation:ns-automation>` and
`<automation:ds-automation>`, to the domain name mapping ({{RFC5731}}). These
elements both have a single boolean "`enabled`" attribute, whose default value
is "`true`".

1. If the value of the "`enabled`" attribute of the `<ds-automation>` element is
"`true`" or "`1`", then the  server **MAY** perform DS automation for the
domain.

2. If the value of the "`enabled`" attribute of the `<ds-automation>` element is
"`false`" or "`0`", then the server **MUST NOT** perform DS automation for the
domain.

Similarly:

1. If the value of the "`enabled`" attribute of the `<ns-automation>` element is
"`true`" or "`1`", then the  server **MAY** perform NS automation for the
domain.

2. If the value of the "`enabled`" attribute of the `<ns-automation>` element is
"`false`" or "`0`", then the server **MUST NOT** perform NS automation for the
domain.

# EPP Command Mapping

## EPP Query Commands

### EPP `<info>` Command

This extension does not add any elements to the EPP `<info>` command described
in the EPP domain mapping ({{RFC5731}}). However, additional elements are
defined for the `<info>` response.

When an `<info>` command has been processed successfully, the EPP `<resData>`
element **MUST** contain child elements as described in the EPP domain mapping
({{RFC5731}}). In addition, the EPP `<extension>` element **MUST** contain a
child `<automation:infData>` element that identifies the extension namespace
if the domain object has data associated with this extension and based on
server policy.  The `<automation:infData>` element **MUST** contain one
`<automation:ns-automation>` element and one `<automation:ds-automation>`
element, which represent the current configuration status for the domain.

Example domain `<info>` response:

#exec sed 's/^/    S: /' examples/info-response.xml

## EPP Transform Commands

### EPP `<create>` Command

This extension defines additional elements for the EPP `<create>` command
described in the EPP domain mapping {{RFC5731}}.  No additional elements are
defined for the EPP `<create>` response.

The EPP `<create>` command provides a transform operation that allows a client
to create a domain object. In addition to the EPP command elements described in
the EPP domain mapping ({{RFC5731}}), the command **MUST** contain an
`<extension>` element, and the `<extension>` element **MUST** contain a child
`<automation:create>` element that identifies the extension namespace if the
client wants to associate data defined in this extension to the domain
object. The `<automation:create>` element **MUST** contain one
`<automation:ns-automation>` element and one `<automation:ds-automation>`
element which represents the desired configuration status for the domain.

* If the server does not support NS automation, then a `<create>` command
containing a `<automation:ns-automation>` whose `enabled` attribute is "`true`"
or "`1`" **MUST** reject the command with a NNNN response.

* If the server does not support DS automation, then a `<create>` command
containing a `<automation:ds-automation>` whose `enabled` attribute is "`true`"
or "`1`" **MUST** reject the command with a NNNN response.

Example domain `<create>` command:

#exec sed 's/^/    C: /' examples/create-command.xml

### EPP `<update>` Command

This extension defines additional elements for the EPP `<update>` command
described in the EPP domain mapping {{RFC5731}}.  No additional elements are
defined for the EPP `<update>` response.

The EPP `<update>` command provides a transform operation that allows a client
to modify the attributes of a domain object. In addition to the EPP command
elements described in the EPP domain mapping, the command **MUST** contain an
`<extension>` element, and the `<extension>` element **MUST** contain a child
`<automation:update>` element that identifies the extension namespace if the
client wants to update the domain object with data defined in this extension.
The `<automation:update>` element element **MUST** contain one
`<automation:ns-automation>` element and one `<automation:ds-automation>`
element which represents the desired configuration status for the domain.

* If the server does not support NS automation, then a `<update>` command
containing a `<automation:ns-automation>` whose `enabled` attribute is "`true`"
or "`1`" **MUST** reject the command with a NNNN response.

* If the server does not support DS automation, then a `<update>` command
containing a `<automation:ds-automation>` whose `enabled` attribute is "`true`"
or "`1`" **MUST** reject the command with a NNNN response.

Example domain `<update>` command:

#exec sed 's/^/    C: /' examples/update-command.xml

# RDAP Status Mapping

Operators of EPP servers who also operate an RDAP server can include an entry
in the "`status`" property of domain responses to allow interested parties to
determine whether delegation automation is enabled or disabled for a given
domain name.

1. Domains for which NS automation is enabled (ie the value of the "`enabled`"
property is "`true`" or "`1`") **MUST** have the "`NS automation enabled`"
value in their "`status`" property.

2. Domains for which NS automation is disabled (ie the value of the "`enabled`"
property is "`false`" or "`0`") **MUST** have the "`NS automation disabled`"
value in their "`status`" property.

3. Domains for which DS automation is enabled (ie the value of the "`enabled`"
property is "`true`" or "`1`") **MUST** have the "`DS automation enabled`"
value in their "`status`" property.

4. Domains for which DS automation is disabled (ie the value of the "`enabled`"
property is "`false`" or "`0`") **MUST** have the "`DS automation disabled`"
value in their "`status`" property.

These two status values will be registered in {{RDAP-JSON-VALUES}} (see
{{iana-rdap}}).

`DS automation enabled` and `DS automation disabled` **MUST NOT** both be
present at the same time. Similarly, `NS automation enabled` and `NS automation
disabled` **MUST NOT** both be present at the same time

# Formal Syntax (XML) {#schema}

An EPP object mapping is specified in XML Schema notation. The formal syntax
presented here is a complete schema representation of the object mapping
suitable for automated validation of EPP XML instances.  The BEGIN and END tags
are not part of the schema; they are used to note the beginning and ending of
the schema for URI registration purposes.

    BEGIN
#exec sed 's/^/    /' schema.xsd
    END

# IANA Considerations

## XML Namespace

This document uses URNs to describe XML namespaces and XML schemas conforming to
a registry mechanism described in {{RFC3688}}. The following URI assignments are
requested of IANA:

Registration for the TTL namespace:

URI: urn:ietf:params:xml:ns:epp:delegation-maintenance-automation-1.0

Registrant Contact: IESG

XML: None. Namespace URIs do not represent an XML specification.

Registration for the TTL XML schema:

URI: urn:ietf:params:xml:schema:epp:delegation-maintenance-automation-1.0

Registrant Contact: IESG

XML: See {{schema}} of this document.

## EPP Extension Registry

IANA is requested to register the EPP extension described in this document in
{{EPP-EXTENSIONS}}, described in {{RFC7451}}. The details of the registration
are as follows:

Name of Extension: DS Automation Status Extension for the Extensible
Provisioning Protocol (EPP)

Document Status: Standards Track

Reference: this document

Registrant: IESG

TLDs: Any

IPR Disclosure: None

Status: Active

Notes: None

## RDAP JSON Values {#iana-rdap}

IANA is requested to list this document as a reference for {{RDAP-JSON-VALUES}}
and register the following values:

Value: NS automation enabled

Type: status

Description: The server MAY perform NS automation for this domain.

Registrant: IETF

Contact Information: iesg@ietf.org

Value: NS automation disabled

Type: status

Description: The server MUST NOT perform NS automation for this domain.

Registrant: IETF

Contact Information: iesg@ietf.org

Reference: this document

Value: DS automation enabled

Type: status

Description: The server MAY perform DS automation for this domain.

Registrant: IETF

Contact Information: iesg@ietf.org

Value: DS automation disabled

Type: status

Description: The server MUST NOT perform DS automation for this domain.

Registrant: IETF

Contact Information: iesg@ietf.org

Reference: this document

# Security Considerations

The mapping extensions described in this document do not provide any security
services beyond those described by EPP ({{RFC5730}}), the EPP domain name
mapping ({{RFC5731}}), and protocol layers used by EPP. The security
considerations  described in these other specifications apply to this
specification as well.

As with other domain object transforms, the EPP transform operations described
in this document **MUST** be restricted to the sponsoring client as
authenticated using the mechanisms described in Sections 2.9.1.1 and 7 of
{{RFC5730}}. Any attempt to perform a transform operation on a domain object by
any client other than the sponsoring client **MUST** be rejected with an
appropriate EPP authorization error.

The provisioning service described in this document involves the exchange of
information that can have an operational impact on the DNS. A trust
relationship **MUST** exist between the EPP client and server using a strong
authentication mechanism.

# Operational Considerations

Server operators **MUST** obey the value for the "`enabled`" property of
`<ns-automation>` and `<ds-automation>` elements, irrespective of the presence
(or absence) of EPP status codes such as `serverUpdateProhibited`.

When the "`enabled`" property is "`false`" or "`0`", the sponsoring client
**MAY** perform NS/DS automation itself, and submit any necessary changes to the
DNSSEC configuration of the domain using an `<update>` command (extended by
{{RFC5910}} as needed).

When the "`enabled`" property is "`true`" or "`1`", the sponsoring client
**SHOULD NOT** perform NS.DS automation, for the reasons outlined in Section
7.2.3 of {{I-D.ietf-dnsop-ds-automation}}.

It is impractical for EPP clients with large portfolios of domain names that
wish to deploy (or decommission) delegation automation themselves to submit
`<update>` commands to enable or disable delegation automation for all domains
under their sponsorship. It is **RECOMMENDED** that server operators provide an
out-of-band method for clients to enable or disable delegation automation for
all domains under their sponsorship in a single operation.

# Change Log

This section is to be removed before publishing as an RFC.

## v01

* Fixed the namespace URI used in the schema and examples.

* Updated to cover NS automation as well as DS automation (thanks Peter Thomassen).

## v00

* Initial version based on conversations within ICANN GDS Technical Services,
and Peter Thomassen.

# Acknowledgements

The author wishes to thank the following for their constructive feedback and
advice during the development of this document:

Andy Newton, Gustavo Lozano, Francisco Arias, Peter Thomassen.
