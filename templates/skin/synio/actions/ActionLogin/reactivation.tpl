{assign var="noSidebar" value=true}
{include file='header.tpl'}

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', () => {
		document.getElementById('reactivation-form').addEventListener('submit', (e) => {
		ls.user.reactivation('reactivation-form');
		e.preventDefault();
		return false;
	});
	document.getElementById('reactivation-form-submit').disabled = false;
});
</script>

<h2 class="page-header">{$aLang.reactivation}</h2>

<form action="{router page='login'}reactivation/" method="POST" id="reactivation-form">
	<p><label for="reactivation-mail">{$aLang.password_reminder_email}</label>
	<input type="text" name="mail" id="reactivation-mail" class="input-text input-width-200" />
	<small class="validate-error-hide validate-error-reactivation"></small></p>

	<button type="submit"  name="submit_reactivation" class="button button-primary" id="reactivation-form-submit" disabled="disabled">{$aLang.reactivation_submit}</button>
</form>



{include file='footer.tpl'}
