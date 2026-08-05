<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="tei xs">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>


    <!-- Witness-level group with collapsing of empty lines -->
    <xsl:template match="tei:lg[@type='witness']">
        <section class="tei-lg tei-lg-witness">
            <xsl:if test="@n">
                <xsl:attribute name="data-siglum">
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:for-each-group select="*" group-adjacent="if (self::tei:l and normalize-space(string-join(.//text(), '')) = '') then 'empty-l' else concat('other-', position())">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'empty-l'">
                        <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}">[…]</div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </section>
    </xsl:template>

    <!-- Higher-level group (e.g. canto/section) with collapsing of empty lines -->
    <xsl:template match="tei:lg[@type='group']">
        <div class="tei-lg tei-lg-group">
            <xsl:for-each-group select="*" group-adjacent="if (self::tei:l and normalize-space(string-join(.//text(), '')) = '') then 'empty-l' else concat('other-', position())">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'empty-l'">
                        <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}">[…]</div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>

    <!-- Stanza / sub-group with collapsing of empty lines -->
    <xsl:template match="tei:lg[@type='sub_group']">
        <xsl:variable name="first-n" select="(tei:l/@n)[1]" as="xs:string?"/>
        <xsl:variable name="last-n" select="(tei:l/@n)[last()]" as="xs:string?"/>
        <div class="tei-lg tei-lg-sub-group">
            <div class="tei-subgroup-label">
                <xsl:text>Vers </xsl:text>
                <xsl:value-of select="$first-n"/>
                <xsl:if test="$last-n and $last-n != $first-n">
                    <xsl:text>–</xsl:text>
                    <xsl:value-of select="$last-n"/>
                </xsl:if>
            </div>
            <div class="tei-subgroup-body">
                <xsl:for-each-group select="*" group-adjacent="if (self::tei:l and normalize-space(string-join(.//text(), '')) = '') then 'empty-l' else concat('other-', position())">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'empty-l'">
                            <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}">[…]</div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </div>
        </div>
    </xsl:template>

    <!-- Verse lines -->
    <xsl:template match="tei:l">
        <xsl:variable name="line_id" select="@xml:id">
        </xsl:variable>
        <div class="tei-line">
            <xsl:if test="@n">
                <xsl:attribute name="id">
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@xml:id">
                <xsl:attribute name="data-n">
                    <xsl:value-of select="$line_id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
<!-- Decorated initials / lombards as TEI c -->
<xsl:template match="tei:c[@type='initial' or @type='lombard']">
<span>
    <xsl:attribute name="class">
        <xsl:text>tei-c tei-c-</xsl:text>
        <xsl:value-of select="@type"/>
    </xsl:attribute>
    <xsl:apply-templates/>
</span>
</xsl:template>

<!-- Inline highlighting for rubrication (and legacy hi initials if any) -->
<xsl:template match="tei:hi[@rend='initial' or @rend='lombard' or @rend='rubric' or @rend='rubrication' or @rend='circumflex']">
<span class="tei-hi">
    <xsl:if test="@rend">
        <xsl:attribute name="class">
            <xsl:text>tei-hi </xsl:text>
            <xsl:text>tei-hi-</xsl:text>
            <xsl:value-of select="@rend"/>
        </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
</span>
</xsl:template>

<!-- Superscript markup: keep the base character on the baseline and
         raise only the marked character(s) above it. -->
<xsl:template match="tei:hi[@rend='superscript']">
<span class="tei-sup">
    <xsl:apply-templates/>
</span>
</xsl:template>

<!-- Abbreviation choices: standard TEI choice with abbr/expan (optional legacy @type) -->
<xsl:template match="tei:choice[tei:abbr and tei:expan]">
<span class="tei-choice tei-choice-abbreviation">
    <xsl:attribute name="data-choice-type">
        <xsl:choose>
            <xsl:when test="@type">
                <xsl:value-of select="@type"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>abbreviation</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
    <span class="tei-orig tei-abbr" data-role="orig">
        <xsl:apply-templates select="tei:abbr"/>
    </span>
    <span class="tei-expan" data-role="expan">
        <xsl:apply-templates select="tei:expan"/>
    </span>
</span>
</xsl:template>

<!-- Generic ligature choices (orig + reg) -->
<xsl:template match="tei:choice[@type='ligature']">
<span class="tei-choice tei-choice-ligature" data-choice-type="ligature">
    <span class="tei-orig" data-role="orig">
        <xsl:apply-templates select="tei:orig"/>
    </span>
    <span class="tei-reg" data-role="reg">
        <xsl:apply-templates select="tei:reg"/>
    </span>
</span>
</xsl:template>

<!-- Et-ligature (& vs. "et") -->
<xsl:template match="tei:choice[@type='et_ligature']">
<span class="tei-choice tei-choice-et-ligature" data-choice-type="et_ligature">
    <span class="tei-orig" data-role="orig">
        <xsl:apply-templates select="tei:orig"/>
    </span>
    <span class="tei-reg" data-role="reg">
        <xsl:apply-templates select="tei:reg"/>
    </span>
</span>
</xsl:template>

</xsl:stylesheet>
