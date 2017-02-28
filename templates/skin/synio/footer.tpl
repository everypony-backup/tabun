				{hook run='content_end'}
			</div> <!-- /content -->
		</div> <!-- /content-wrapper -->
	</div> <!-- /wrapper -->


	
	<footer id="footer">
		<p>Все права принадлежат пони. Весь мир принадлежит пони.</p>
		<div class="text version">
            <div>Версия Табуна: <strong>{cfg name='misc.ver.code'}</strong></div>
            {if {cfg name='misc.debug'} == true}
                <div>Версия фронтенда: <strong>{cfg name='misc.ver.front'}</strong></div>
            {/if}
            <div><a href="https://bitbucket.org/Orhideous/tabun/issues/new" target="_blank">Сообщить об ошибке</a></div>
		</div>
		{hook run='footer_end'}
	</footer>
</div> <!-- /container -->

{include file='toolbar.tpl'}
<script type="text/javascript">
    var LIVESTREET_SECURITY_KEY = '{$LIVESTREET_SECURITY_KEY}';
    var RECAPTCHA_KEY = '{cfg name='recaptcha.key'}';
</script>
<script src="{cfg name='path.static.url'}/{cfg name='misc.ver.front'}/vendor.bundle.js" type="text/javascript"></script>
<script src="{cfg name='path.static.url'}/{cfg name='misc.ver.front'}/main.bundle.js" type="text/javascript"></script>

<script type="text/javascript">
    ls.tools.registry.loadJSON({json var=$aFrontendRegistry});
    ls.lang.load({json var = $aLangJs});
</script>
{if isset($scripts)}
    {foreach from=$scripts item=item}
        <script src="{cfg name='path.static.url'}/{cfg name='misc.ver.front'}/{$item}.bundle.js" type="text/javascript"></script>
    {/foreach}
{/if}
{hook run='body_end'}

</body>
</html>
