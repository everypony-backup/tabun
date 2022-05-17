<ul class="latest-list">
	{foreach from=$aComments item=oComment name="cmt"}
		{assign var="oUser" value=$oComment->getUser()}
		{assign var="oTopic" value=$oComment->getTarget()}
		{assign var="oBlog" value=$oTopic->getBlog()}
		
		<li>
			<p>
				<a href="{$oUser->getUserWebPath()}" class="author">{$oUser->getLogin()}</a> в <a href="{$oBlog->getUrlFull()}" class="stream-blog">{$oBlog->getTitle()|escape:'html'}</a>  
			</p>
			<a href="{$oTopic->getUrl()}#comment{$oComment->getId()}" class="stream-topic">{$oTopic->getTitle()|escape:'html'}</a>
			<span class="block-item-comments"><i class="icon-synio-comments-small"></i>{$oTopic->getCountComment()}</span>
		</li>
	{/foreach}
</ul>


<footer>
	<a href="{router page='comments'}">{$aLang.block_stream_comments_all}</a> · <a href="{router page='rss'}allcomments/">RSS</a>
</footer>
