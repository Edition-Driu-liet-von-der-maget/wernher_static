<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei xs">

    <xsl:template name="render_edition_metadata">
        <xsl:variable name="msDesc" select=".//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc[1]"/>
        <xsl:if test="$msDesc">
            <section class="edition-metadata-block" aria-labelledby="edition-metadata-heading">
                <details class="edition-metadata-panel">
                    <summary class="edition-metadata-summary">
                        <span id="edition-metadata-heading">Metadaten zur Handschrift</span>
                    </summary>

                    <div class="edition-metadata-content">
                        <xsl:if test="$msDesc/tei:msIdentifier">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Identifikation</h2>
                                <dl class="metadata-list">
                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:idno[@type='siglum']">
                                        <div class="metadata-item">
                                            <dt>Siglum</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msIdentifier/tei:idno[@type='siglum'][1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:country">
                                        <div class="metadata-item">
                                            <dt>Land</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msIdentifier/tei:country[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:settlement">
                                        <div class="metadata-item">
                                            <dt>Ort</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msIdentifier/tei:settlement[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:repository">
                                        <div class="metadata-item">
                                            <dt>Aufbewahrungsort</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msIdentifier/tei:repository[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:idno[@type='signature']">
                                        <div class="metadata-item">
                                            <dt>Signatur(en)</dt>
                                            <dd>
                                                <xsl:for-each select="$msDesc/tei:msIdentifier/tei:idno[@type='signature']">
                                                    <div>
                                                        <xsl:value-of select="."/>
                                                    </div>
                                                </xsl:for-each>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:idno[@type='handschriftencensus_id']">
                                        <div class="metadata-item">
                                            <dt>Handschriftencensus-ID</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msIdentifier/tei:idno[@type='handschriftencensus_id'][1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msIdentifier/tei:idno[@type='handschriftencensus_url']">
                                        <div class="metadata-item">
                                            <dt>Handschriftencensus</dt>
                                            <dd>
                                                <a href="{$msDesc/tei:msIdentifier/tei:idno[@type='handschriftencensus_url'][1]}">
                                                    <xsl:value-of select="$msDesc/tei:msIdentifier/tei:idno[@type='handschriftencensus_url'][1]"/>
                                                </a>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                </dl>
                            </section>
                        </xsl:if>

                        <xsl:if test="$msDesc/tei:msContents">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Inhalt und Sprache</h2>
                                <dl class="metadata-list">
                                    <xsl:if test="$msDesc/tei:msContents/tei:summary">
                                        <div class="metadata-item">
                                            <dt>Inhalt</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msContents/tei:summary[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$msDesc/tei:msContents/tei:textLang">
                                        <div class="metadata-item">
                                            <dt>Schreibsprache</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:msContents/tei:textLang[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                </dl>
                            </section>
                        </xsl:if>

                        <xsl:if test="$msDesc/tei:physDesc">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Kodikologie</h2>
                                <dl class="metadata-list">
                                    <xsl:if test="$msDesc/tei:physDesc//tei:material">
                                        <div class="metadata-item">
                                            <dt>Material</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:physDesc//tei:material[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>

                                    <xsl:for-each select="$msDesc/tei:physDesc//tei:support/tei:p[@type='extent' or @type='leaf_size' or @type='writing_area']">
                                        <div class="metadata-item">
                                            <dt>
                                                <xsl:choose>
                                                    <xsl:when test="@type='extent'">Umfang</xsl:when>
                                                    <xsl:when test="@type='leaf_size'">Blattgröße</xsl:when>
                                                    <xsl:when test="@type='writing_area'">Schriftraum</xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="@type"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </dt>
                                            <dd>
                                                <xsl:value-of select="."/>
                                            </dd>
                                        </div>
                                    </xsl:for-each>

                                    <xsl:if test="$msDesc/tei:physDesc//tei:layout">
                                        <div class="metadata-item">
                                            <dt>Layout</dt>
                                            <dd>
                                                <xsl:if test="$msDesc/tei:physDesc//tei:layout[1]/@columns">
                                                    <div>Spalten: <xsl:value-of select="$msDesc/tei:physDesc//tei:layout[1]/@columns"/></div>
                                                </xsl:if>
                                                <xsl:if test="$msDesc/tei:physDesc//tei:layout[1]/@writtenLines">
                                                    <div>Zeilen: <xsl:value-of select="$msDesc/tei:physDesc//tei:layout[1]/@writtenLines"/></div>
                                                </xsl:if>
                                                <xsl:for-each select="$msDesc/tei:physDesc//tei:layout[1]/tei:p[@type='lines_per_page' or @type='verse_layout' or @type='features']">
                                                    <div>
                                                        <xsl:choose>
                                                            <xsl:when test="@type='lines_per_page'">Zeilen pro Seite: </xsl:when>
                                                            <xsl:when test="@type='verse_layout'">Versgestaltung: </xsl:when>
                                                            <xsl:when test="@type='features'">Besonderheiten: </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="@type"/>: 
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:value-of select="."/>
                                                    </div>
                                                </xsl:for-each>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                </dl>
                            </section>
                        </xsl:if>

                        <xsl:if test="$msDesc/tei:history">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Datierung und Herkunft</h2>
                                <dl class="metadata-list">
                                    <xsl:if test="$msDesc/tei:history/tei:origin/tei:origDate">
                                        <div class="metadata-item">
                                            <dt>Entstehungszeit</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:history/tei:origin/tei:origDate[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                    <xsl:if test="$msDesc/tei:history/tei:origin/tei:origPlace">
                                        <div class="metadata-item">
                                            <dt>Entstehungsort</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:history/tei:origin/tei:origPlace[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                    <xsl:if test="$msDesc/tei:history/tei:provenance">
                                        <div class="metadata-item">
                                            <dt>Frühere Aufbewahrung</dt>
                                            <dd>
                                                <xsl:value-of select="$msDesc/tei:history/tei:provenance[1]"/>
                                            </dd>
                                        </div>
                                    </xsl:if>
                                </dl>
                            </section>
                        </xsl:if>

                        <xsl:if test="$msDesc/tei:additional/tei:note">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Anmerkungen</h2>
                                <ul class="metadata-notes">
                                    <xsl:for-each select="$msDesc/tei:additional/tei:note">
                                        <li>
                                            <xsl:value-of select="."/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </section>
                        </xsl:if>

                        <xsl:if test="$msDesc/tei:msPart">
                            <section class="metadata-section">
                                <h2 class="metadata-section-title">Teilüberlieferung</h2>
                                <xsl:for-each select="$msDesc/tei:msPart">
                                    <div class="metadata-part">
                                        <h3 class="metadata-part-title">
                                            <xsl:text>Teil </xsl:text>
                                            <xsl:value-of select="@n"/>
                                        </h3>
                                        <dl class="metadata-list">
                                            <xsl:if test="tei:msIdentifier/tei:country">
                                                <div class="metadata-item">
                                                    <dt>Land</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:msIdentifier/tei:country[1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                            <xsl:if test="tei:msIdentifier/tei:settlement">
                                                <div class="metadata-item">
                                                    <dt>Ort</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:msIdentifier/tei:settlement[1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                            <xsl:if test="tei:msIdentifier/tei:repository">
                                                <div class="metadata-item">
                                                    <dt>Aufbewahrungsort</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:msIdentifier/tei:repository[1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                            <xsl:if test="tei:msIdentifier/tei:idno[@type='signature']">
                                                <div class="metadata-item">
                                                    <dt>Signatur</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:msIdentifier/tei:idno[@type='signature'][1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                            <xsl:if test="tei:physDesc//tei:extent">
                                                <div class="metadata-item">
                                                    <dt>Umfang</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:physDesc//tei:extent[1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                            <xsl:if test="tei:history/tei:provenance">
                                                <div class="metadata-item">
                                                    <dt>Frühere Aufbewahrung</dt>
                                                    <dd>
                                                        <xsl:value-of select="tei:history/tei:provenance[1]"/>
                                                    </dd>
                                                </div>
                                            </xsl:if>
                                        </dl>
                                    </div>
                                </xsl:for-each>
                            </section>
                        </xsl:if>
                    </div>
                </details>
            </section>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>