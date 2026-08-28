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
                        <!-- <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}"><span class="tei-vers-number tei-vers-number-global"></span><span class="tei-vers-number tei-vers-number-local"></span>[…]</div> -->
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
                        <!-- <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}"><span class="tei-vers-number tei-vers-number-global"></span><span class="tei-vers-number tei-vers-number-local"></span>[…]</div> -->
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
            <div class="tei-subgroup-body">
                <xsl:for-each-group select="*" group-adjacent="if (self::tei:l and normalize-space(string-join(.//text(), '')) = '') then 'empty-l' else concat('other-', position())">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'empty-l'">
                            <!-- <div class="tei-line tei-line-gap" data-missing-lines="{count(current-group())}"><span class="tei-vers-number tei-vers-number-global"></span><span class="tei-vers-number tei-vers-number-local"></span>[…]</div> -->
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
            <span class="tei-vers-number tei-vers-number-global">
                <xsl:value-of select="substring-after(@n, 'v_')"/>
            </span>
            <span class="tei-vers-number tei-vers-number-local">
                <xsl:value-of select="substring-after(@xml:id, 'v_')"/>
            </span>
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

<!--
         Superscript as Unicode modifier / superscript letters so the font
         places them above the baseline (no CSS stacking hacks).
         Data inventory: s o v e n i u (and a few others as fallback).
    -->
    <xsl:template match="tei:hi[@rend='superscript']">
        <xsl:variable name="raw" select="normalize-space(string-join(.//text(), ''))"/>
        <xsl:variable name="mapped">
            <xsl:for-each select="string-to-codepoints($raw)">
                <xsl:variable name="ch" select="codepoints-to-string(.)"/>
                <xsl:choose>
                    <xsl:when test="$ch = 'a'">ᵃ</xsl:when>
                    <xsl:when test="$ch = 'b'">ᵇ</xsl:when>
                    <xsl:when test="$ch = 'c'">ᶜ</xsl:when>
                    <xsl:when test="$ch = 'd'">ᵈ</xsl:when>
                    <xsl:when test="$ch = 'e'">ᵉ</xsl:when>
                    <xsl:when test="$ch = 'f'">ᶠ</xsl:when>
                    <xsl:when test="$ch = 'g'">ᵍ</xsl:when>
                    <xsl:when test="$ch = 'h'">ʰ</xsl:when>
                    <xsl:when test="$ch = 'i'">ⁱ</xsl:when>
                    <xsl:when test="$ch = 'j'">ʲ</xsl:when>
                    <xsl:when test="$ch = 'k'">ᵏ</xsl:when>
                    <xsl:when test="$ch = 'l'">ˡ</xsl:when>
                    <xsl:when test="$ch = 'm'">ᵐ</xsl:when>
                    <xsl:when test="$ch = 'n'">ⁿ</xsl:when>
                    <xsl:when test="$ch = 'o'">ᵒ</xsl:when>
                    <xsl:when test="$ch = 'p'">ᵖ</xsl:when>
                    <xsl:when test="$ch = 'r'">ʳ</xsl:when>
                    <xsl:when test="$ch = 's'">ˢ</xsl:when>
                    <xsl:when test="$ch = 't'">ᵗ</xsl:when>
                    <xsl:when test="$ch = 'u'">ᵘ</xsl:when>
                    <xsl:when test="$ch = 'v'">ᵛ</xsl:when>
                    <xsl:when test="$ch = 'w'">ʷ</xsl:when>
                    <xsl:when test="$ch = 'x'">ˣ</xsl:when>
                    <xsl:when test="$ch = 'y'">ʸ</xsl:when>
                    <xsl:when test="$ch = 'z'">ᶻ</xsl:when>
                    <xsl:when test="$ch = 'A'">ᴬ</xsl:when>
                    <xsl:when test="$ch = 'B'">ᴮ</xsl:when>
                    <xsl:when test="$ch = 'D'">ᴰ</xsl:when>
                    <xsl:when test="$ch = 'E'">ᴱ</xsl:when>
                    <xsl:when test="$ch = 'G'">ᴳ</xsl:when>
                    <xsl:when test="$ch = 'H'">ᴴ</xsl:when>
                    <xsl:when test="$ch = 'I'">ᴵ</xsl:when>
                    <xsl:when test="$ch = 'J'">ᴶ</xsl:when>
                    <xsl:when test="$ch = 'K'">ᴷ</xsl:when>
                    <xsl:when test="$ch = 'L'">ᴸ</xsl:when>
                    <xsl:when test="$ch = 'M'">ᴹ</xsl:when>
                    <xsl:when test="$ch = 'N'">ᴺ</xsl:when>
                    <xsl:when test="$ch = 'O'">ᴼ</xsl:when>
                    <xsl:when test="$ch = 'P'">ᴾ</xsl:when>
                    <xsl:when test="$ch = 'R'">ᴿ</xsl:when>
                    <xsl:when test="$ch = 'T'">ᵀ</xsl:when>
                    <xsl:when test="$ch = 'U'">ᵁ</xsl:when>
                    <xsl:when test="$ch = 'V'">ⱽ</xsl:when>
                    <xsl:when test="$ch = 'W'">ᵂ</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$ch"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <span class="tei-sup" aria-label="{$raw}">
            <xsl:value-of select="$mapped"/>
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
