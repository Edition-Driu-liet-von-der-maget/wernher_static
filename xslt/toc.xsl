<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar" version="2.0" exclude-result-prefixes="xsl tei xs local">

    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <!-- imports as in your original -->
    <xsl:import href="partials/html_navbar.xsl"/>
    <xsl:import href="partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/tabulator_dl_buttons.xsl"/>
    <xsl:import href="partials/tabulator_js.xsl"/>
    <xsl:import href="partials/blockquote.xsl"/>
    <xsl:import href="partials/zotero.xsl"/>

    <!-- Utility: remove bracketed sources like " (Schneider ...)" -->
    <xsl:function name="local:strip-parens" as="xs:string">
        <xsl:param name="s" as="xs:string?"/>
        <xsl:sequence select="normalize-space(replace(normalize-space(string($s)), '\s*\([^)]*\)', ''))"/>
    </xsl:function>

    <!-- Utility: distinct, non-empty normalized strings -->
    <xsl:function name="local:distinct-nonempty" as="xs:string*">
        <xsl:param name="seq" as="xs:string*"/>
        <xsl:sequence select="distinct-values(for $s in $seq return normalize-space($s))[normalize-space(.) ne '']"/>
    </xsl:function>

    <!-- Utility: pick siglum (prefer idno[@type='siglum'], fallback to first token of title) -->
    <xsl:function name="local:get-siglum" as="xs:string">
        <xsl:param name="teiRoot" as="element(tei:TEI)"/>
        <xsl:variable name="fromIdno" select="normalize-space(($teiRoot//tei:sourceDesc//tei:msDesc/tei:msIdentifier/tei:idno[@type='siglum'])[1])"/>
        <xsl:variable name="fromTitle" select="replace(normalize-space(string(($teiRoot//tei:fileDesc/tei:titleStmt/tei:title)[1])),
                      '^\s*([^\s(]+).*$', '$1')"/>
        <xsl:sequence select="if ($fromIdno) then $fromIdno else $fromTitle"/>
    </xsl:function>


    <!-- helper: get all places (country) from header -->
    <xsl:function name="local:get-places" as="xs:string*" xmlns:tei="http://www.tei-c.org/ns/1.0">
        <xsl:param name="tei" as="element(tei:TEI)"/>

        <!-- Collect all msIdentifier nodes -->
        <xsl:variable name="allMsIdentifiers" select="$tei//tei:sourceDesc//tei:msDesc//tei:msIdentifier"/>

        <!-- Build a sequence of "settlement (country)" without using let/where -->
        <xsl:variable name="seq" as="xs:string*">
            <xsl:for-each select="$allMsIdentifiers">
                <xsl:variable name="sett" select="normalize-space(string(tei:settlement))"/>
                <xsl:variable name="country" select="normalize-space(string(tei:country))"/>
                <xsl:variable name="p" select="if ($sett and $country) then concat($sett, ' (', $country, ')')
                else if ($sett) then $sett
                else if ($country) then $country
                else ''"/>
                <xsl:if test="normalize-space($p) ne ''">
                    <xsl:sequence select="$p"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <!-- Deduplicate and return -->
        <xsl:sequence select="distinct-values($seq)"/>
    </xsl:function>


    <!-- Main page -->
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Inhaltsverzeichnis'"/>
        <xsl:variable name="link" select="'toc.html'"/>

        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param name="pageId" select="$link"/>
                    <xsl:with-param name="zoteroTitle" select="$doc_title"/>
                </xsl:call-template>
            </head>

            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>

                <main class="flex-shrink-0 flex-grow-1">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" class="ps-5 p-3">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of select="$project_short_title"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <xsl:value-of select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>

                    <div class="container">
                        <h1>
                            <xsl:value-of select="$doc_title"/>
                        </h1>

                        <table id="myTable">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Siglum</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Archive signature(s)</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Place(s)</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Material info</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Origin date</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Language/Dialect</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="collection('../data/editions?select=*.xml')//tei:TEI">
                                    <xsl:variable name="tei" select="."/>
                                    <xsl:variable name="full_path" select="document-uri(/)"/>
                                    <xsl:variable name="filename" select="tokenize($full_path, '/')[last()]"/>
                                    <xsl:variable name="href" select="replace($filename, '\.xml$', '.html')"/>

                                    <!-- Gather msIdentifiers from top-level msDesc and any msPart -->
                                    <xsl:variable name="allMsIdentifiers" select="$tei//tei:sourceDesc//tei:msDesc//tei:msIdentifier"/>

                                    <!-- Siglum -->
                                    <xsl:variable name="siglum" select="local:get-siglum($tei)"/>

                                    <!-- Signatures -->
                                    <xsl:variable name="signatures" select="local:distinct-nonempty($allMsIdentifiers/tei:idno[@type='signature']/string())"/>


                                    <!-- Origin date(s), bracketed sources removed -->
                                    <xsl:variable name="originDates" select="local:distinct-nonempty(
                              for $d in $tei//tei:history/tei:origin/tei:origDate
                              return local:strip-parens(string($d))
                            )"/>
                                    <xsl:variable name="materialBits" select="local:distinct-nonempty((
            $tei//tei:physDesc//tei:support/tei:material/string(),
            $tei//tei:physDesc//tei:support/tei:extent/string(), $tei//tei:physDesc//tei:support/tei:p[@type=('extent','leaf_size','writing_area')]/string()
          ))"/>


                                    <!-- Language/Dialect, bracketed sources removed -->
                                    <xsl:variable name="langInfo" select="local:distinct-nonempty(
                              for $l in $tei//tei:msContents/tei:textLang
                              return local:strip-parens(string($l))
                            )"/>

                                    <tr>
                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="$siglum"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="string-join($signatures, '; ')"/>
                                            </a>
                                        </td>

                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="string-join(local:get-places(.), '; ')"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="string-join($materialBits, ' | ')"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="string-join($originDates, '; ')"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="{$href}" class="text-reset text-decoration-none">
                                                <xsl:value-of select="string-join($langInfo, '; ')"/>
                                            </a>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>

                        <xsl:call-template name="tabulator_dl_buttons"/>

                        <div class="text-center p-4">
                            <xsl:call-template name="blockquote">
                                <xsl:with-param name="pageId" select="'toc.html'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                </main>

                <xsl:call-template name="html_footer"/>
                <xsl:call-template name="tabulator_js"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>