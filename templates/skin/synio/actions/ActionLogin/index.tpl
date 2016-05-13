{assign var="noSidebar" value=true}
{include file='header.tpl'}

<h2 class="page-header">{$aLang.user_authorization}</h2>
<div id="action_login"></div>
<br />
<br />
<a href="{router page='registration'}">{$aLang.user_registration}</a><br />
<a href="{router page='login'}reminder/">{$aLang.user_password_reminder}</a>

{include file='footer.tpl'}