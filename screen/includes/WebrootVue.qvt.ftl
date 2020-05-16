<#--
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->
<div id="apps-root"><#-- NOTE: webrootVue component attaches here, uses this and below for template -->
    <input type="hidden" id="confMoquiSessionToken" value="${ec.web.sessionToken}">
    <input type="hidden" id="confAppHost" value="${ec.web.getHostName(true)}">
    <input type="hidden" id="confAppRootPath" value="${ec.web.servletContext.contextPath}">
    <input type="hidden" id="confBasePath" value="${ec.web.servletContext.contextPath}/apps">
    <input type="hidden" id="confLinkBasePath" value="${ec.web.servletContext.contextPath}/qapps">
    <input type="hidden" id="confUserId" value="${ec.user.userId!''}">
    <input type="hidden" id="confLocale" value="${ec.user.locale.toLanguageTag()}">
    <#assign navbarCompList = sri.getThemeValues("STRT_HEADER_NAVBAR_COMP")>
    <#list navbarCompList! as navbarCompUrl><input type="hidden" class="confNavPluginUrl" value="${navbarCompUrl}"></#list>
    <#if hideNav! != 'true'>
    <div id="top">
        <#--  navbar-fixed-top navbar-static-top -->
        <q-bar class="bg-black text-white">
            <#assign headerLogoList = sri.getThemeValues("STRT_HEADER_LOGO")>
            <#if headerLogoList?has_content>
                <m-link href="/apps"><q-avatar square>
                    <img src="${sri.buildUrl(headerLogoList?first).getUrl()}" alt="Home">
                </q-avatar></m-link>
            </#if>
            <#assign headerTitleList = sri.getThemeValues("STRT_HEADER_TITLE")>
            <#if headerTitleList?has_content>
                <div class="text-weight-bold">${ec.resource.expand(headerTitleList?first, "")}</div>
            </#if>

            <q-breadcrumbs active-color="white" style="font-size: 16px">
                <template v-slot:separator><q-icon size="1.5em" name="o_chevron_right" color="primary"></q-icon></template>

                <template v-for="(navMenuItem, menuIndex) in navMenuList">
                    <q-breadcrumbs-el v-if="menuIndex < (navMenuList.length - 1)">
                        <m-link v-if="navMenuItem.hasTabMenu" :href="getNavHref(menuIndex)">{{navMenuItem.title}}</m-link>
                        <template v-else-if="navMenuItem.subscreens && navMenuItem.subscreens.length > 1">
                            <div class="cursor-pointer non-selectable">{{navMenuItem.title}}
                                <q-menu><q-list dense style="min-width: 100px">
                                    <q-item v-for="subscreen in navMenuItem.subscreens" :class="{'bg-primary':subscreen.active, 'text-white':subscreen.active}" clickable v-close-popup>
                                        <q-item-section>
                                            <m-link :href="subscreen.pathWithParams">
                                                <template v-if="subscreen.image">
                                                    <i v-if="subscreen.imageType === 'icon'" :class="subscreen.image" style="padding-right: 4px;"></i>
                                                    <img v-else :src="subscreen.image" :alt="subscreen.title" width="18" style="padding-right: 4px;">
                                                </template>
                                                <i v-else class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                                                {{subscreen.title}}
                                            </m-link></li>
                                        </q-item-section>
                                    </q-item>
                                </q-list></q-menu>
                            </div>
                        </template>
                        <m-link v-else :href="getNavHref(menuIndex)">{{navMenuItem.title}}</m-link>
                    </q-breadcrumbs-el>
                </template>
                <q-breadcrumbs-el v-if="navMenuList.length > 0">
                    <m-link :href="getNavHref(navMenuList.length - 1)">{{navMenuList[navMenuList.length - 1].title}}</m-link>
                </q-breadcrumbs-el>
            </q-breadcrumbs>

            <q-space></q-space>

            <#-- TODO: add right side buttons/etc from below -->

            <#-- dark/light switch -->
            <q-btn @click.prevent="switchDarkLight()" icon="o_invert_colors">
                <q-tooltip>${ec.l10n.localize("Switch Dark/Light")}</q-tooltip></q-btn>
        </q-bar>


        <div id="navbar-buttons" class="collapse navbar-collapse navbar-ex1-collapse">
            <#-- logout button -->
            <a href="${sri.buildUrl("/Login/logout").url}" data-toggle="tooltip" data-original-title="${ec.l10n.localize("Logout")} ${(ec.user.userAccount.userFullName)!''}"
                   onclick="return confirm('${ec.l10n.localize("Logout")} ${(ec.user.userAccount.userFullName)!''}?')"
                   data-placement="bottom" class="btn btn-danger btn-sm navbar-btn navbar-right"><i class="glyphicon glyphicon-off"></i></a>
            <#-- screen history menu -->
            <#-- get initial history from server? <#assign screenHistoryList = ec.web.getScreenHistory()><#list screenHistoryList as screenHistory><#if (screenHistory_index >= 25)><#break></#if>{url:pathWithParams, name:title}</#list> -->
            <div id="history-menu" class="nav navbar-right dropdown">
                <a id="history-menu-link" href="#" class="dropdown-toggle btn btn-default btn-sm navbar-btn" data-toggle="dropdown" title="${ec.l10n.localize("Screen History")}">
                    <i class="glyphicon glyphicon-menu-hamburger"></i></a>
                <ul class="dropdown-menu">
                    <li v-for="histItem in navHistoryList"><m-link :href="histItem.pathWithParams">
                        <template v-if="histItem.image">
                            <i v-if="histItem.imageType === 'icon'" :class="histItem.image" style="padding-right: 8px;"></i>
                            <img v-else :src="histItem.image" :alt="histItem.title" width="18" style="padding-right: 4px;">
                        </template>
                        <i v-else class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                        {{histItem.title}}</m-link></li>
                </ul>
            </div>
            <#-- screen history previous screen -->
            <#-- disable this for now to save space, not commonly used and limited value vs browser back:
            <a href="#" @click.prevent="goPreviousScreen()" data-toggle="tooltip" data-original-title="${ec.l10n.localize("Previous Screen")}"
               data-placement="bottom" class="btn btn-default btn-sm navbar-btn navbar-right"><i class="glyphicon glyphicon-menu-left"></i></a>
            -->
            <#-- notify history -->
            <div id="notify-history-menu" class="nav navbar-right dropdown">
                <a id="notify-history-menu-link" href="#" class="dropdown-toggle btn btn-default btn-sm navbar-btn" data-toggle="dropdown" title="${ec.l10n.localize("Notify History")}">
                    <i class="glyphicon glyphicon-exclamation-sign"></i></a>
                <ul class="dropdown-menu" @click.prevent="stopProp">
                    <li v-for="histItem in notifyHistoryList">
                        <#-- NOTE: don't use v-html for histItem.message, may contain input repeated back so need to encode for security (make sure scripts not run, etc) -->
                        <div :class="'alert alert-' + histItem.type" @click.prevent="stopProp" role="alert"><strong>{{histItem.time}}</strong> <span>{{histItem.message}}</span></div>
                    </li>
                </ul>
            </div>

            <#-- QZ print options placeholder -->
            <component :is="qzVue" ref="qzVue"></component>

            <#-- nav plugins -->
            <template v-for="navPlugin in navPlugins"><component :is="navPlugin"></component></template>

            <#-- screen documentation/help -->
            <div id="document-menu" class="nav navbar-right dropdown" :class="{hidden:!documentMenuList.length}">
                <a id="document-menu-link" href="#" class="dropdown-toggle btn btn-info btn-sm navbar-btn" data-toggle="dropdown" title="Documentation">
                    <i class="glyphicon glyphicon-question-sign"></i></a>
                <ul class="dropdown-menu">
                    <li v-for="screenDoc in documentMenuList">
                        <a href="#" @click.prevent="showScreenDocDialog(screenDoc.index)">{{screenDoc.title}}</a></li>
                </ul>
            </div>

            <#-- spinner, usually hidden -->
            <div class="navbar-right" style="padding:10px 4px 6px 4px;" :class="{ hidden: loading < 1 }"><div class="spinner small"><div>&nbsp;</div></div></div>
        </div>
    </div>
    </#if>

    <div id="content"><div class="inner"><div class="container-fluid">
        <subscreens-active></subscreens-active>
    </div></div></div>

    <#if hideNav! != 'true'>
    <div id="footer" class="bg-dark">
        <#assign footerItemList = sri.getThemeValues("STRT_FOOTER_ITEM")>
        <div id="apps-footer-content">
            <#list footerItemList! as footerItem>
                <#assign footerItemTemplate = footerItem?interpret>
                <@footerItemTemplate/>
            </#list>
        </div>
    </div>
    </#if>
</div>

<div id="screen-document-dialog" class="modal dynamic-dialog" aria-hidden="true" style="display: none;" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">${ec.l10n.localize("Documentation")}</h4>
            </div>
            <div class="modal-body" id="screen-document-dialog-body">
                <div class="spinner"><div>&nbsp;</div></div>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-primary" data-dismiss="modal">${ec.l10n.localize("Close")}</button></div>
        </div>
    </div>
</div>

<script>
    window.quasarConfig = {
        brand: { // this will NOT work on IE 11
            // primary: '#e46262',
            // ... or all other brand colors
        },
        // notify: {...}, // default set of options for Notify Quasar plugin
        // loading: {...}, // default set of options for Loading Quasar plugin
        // loadingBar: { ... }, // settings for LoadingBar Quasar plugin
        // ..and many more (check Installation card on each Quasar component/directive/plugin)
    }
</script>
