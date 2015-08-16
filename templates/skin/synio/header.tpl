<!doctype html>
<html lang="ru">
<head>
    {hook run='html_head_begin'}

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>{$sHtmlTitle}</title>

    <meta name="description" content="{$sHtmlDescription}">
    <meta name="keywords" content="{$sHtmlKeywords}">

    <link rel="stylesheet" type="text/css" href="/static/styles.css">
    {$aHtmlHeadFiles.css}

    <link href="/favicon.ico" rel="shortcut icon"/>
    <link rel="search" type="application/opensearchdescription+xml" href="{router page='search'}opensearch/" title="{cfg name='view.name'}"/>

    {if $aHtmlRssAlternate}
        <link rel="alternate" type="application/rss+xml" href="{$aHtmlRssAlternate.url}"
              title="{$aHtmlRssAlternate.title}">
    {/if}

    {if $sHtmlCanonical}
        <link rel="canonical" href="{$sHtmlCanonical}"/>
    {/if}

    {if $bRefreshToHome}
        <meta HTTP-EQUIV="Refresh" CONTENT="3; URL={cfg name='path.root.web'}/">
    {/if}
    {include 'analytics.tpl'}
    <script type="text/javascript">
        var DIR_WEB_ROOT = '{cfg name="path.root.web"}';
        var DIR_STATIC_SKIN = '{cfg name="path.static.skin"}';
        var DIR_ROOT_ENGINE_LIB = '{cfg name="path.root.engine_lib"}';
        var LIVESTREET_SECURITY_KEY = '{$LIVESTREET_SECURITY_KEY}';
        var SESSION_ID = '{$_sPhpSessionId}';

        var aRouter = [];
        {foreach from=$aRouter key=sPage item=sPath}
        aRouter['{$sPage}'] = '{$sPath}';
        {/foreach}
    </script>

    {$aHtmlHeadFiles.js}
    <script type="text/javascript">
        ls.lang.load({json var = $aLangJs});
        ls.registry.set('comment_max_tree', {json var=$oConfig->Get('module.comment.max_tree')});
        ls.registry.set('block_stream_show_tip', {json var=$oConfig->Get('block.stream.show_tip')});
    </script>

    {hook run='html_head_end'}
</head>

{add_block group='toolbar' name='toolbar_admin.tpl' priority=100}

<body class="width-fixed">
{hook run='body_begin'}


{if $oUserCurrent}
    {include file='window_write.tpl'}
    {include file='window_favourite_form_tags.tpl'}
{else}
    {include file='window_login.tpl'}
{/if}

<div id="widemode">
    <a id="despoil">Despoil</a>
    <a id="widemode-switch">Wide mode &harr;</a>
    <a id="up-switch"></a>
    <a id="down-switch"></a>
</div>

<div id="container" class="{hook run='container_class'}">
    {include file='header_top.tpl'}

    <div id="wrapper" class="{if $noSidebar}no-sidebar{/if}{hook run='wrapper_class'}">
        {if !$noSidebar}
            {include file='sidebar.tpl'}
        {/if}

        <div id="content-wrapper" {if $sidebarPosition == 'left'}class="content-profile"{/if}>
            <div id="content" role="main" {if $sMenuItemSelect=='profile'}itemscope
                 itemtype="http://data-vocabulary.org/Person"{/if}>
                {include file='nav_content.tpl'}
                {include file='system_message.tpl'}

                {hook run='content_begin'}
