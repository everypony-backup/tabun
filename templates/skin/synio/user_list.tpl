<table class="table table-users">
	{if $bUsersUseOrder}
		<thead>
			<tr>
				<th class="cell-name cell-tab">
					<div class="cell-tab-inner {if $sUsersOrder=='user_login'}active{/if}"><a href="{$sUsersRootPage}?order=user_login&order_way={if $sUsersOrder=='user_login'}{$sUsersOrderWayNext}{else}{$sUsersOrderWay}{/if}" {if $sUsersOrder=='user_login'}class="{$sUsersOrderWay}"{/if}><span>{$aLang.user}</span></a></div>
				</th>
				<th>&nbsp;</th>
				<th class="cell-skill cell-tab">
					<div class="cell-tab-inner {if $sUsersOrder=='user_skill'}active{/if}"><a href="{$sUsersRootPage}?order=user_skill&order_way={if $sUsersOrder=='user_skill'}{$sUsersOrderWayNext}{else}{$sUsersOrderWay}{/if}" {if $sUsersOrder=='user_skill'}class="{$sUsersOrderWay}"{/if}><span>{$aLang.user_skill}</span></a></div>
				</th>
				<th class="cell-rating cell-tab">
					<div class="cell-tab-inner {if $sUsersOrder=='user_rating'}active{/if}"><a href="{$sUsersRootPage}?order=user_rating&order_way={if $sUsersOrder=='user_rating'}{$sUsersOrderWayNext}{else}{$sUsersOrderWay}{/if}" {if $sUsersOrder=='user_rating'}class="{$sUsersOrderWay}"{/if}><span>{$aLang.user_rating}</span></a></div>
				</th>
			</tr>
		</thead>
	{else}
		<thead>
			<tr>
				<th class="cell-name cell-tab"><div class="cell-tab-inner">{$aLang.user}</div></th>
				<th>&nbsp;</th>
				<th class="cell-skill cell-tab"><div class="cell-tab-inner">{$aLang.user_skill}</div></th>
				<th class="cell-rating cell-tab">
					<div class="cell-tab-inner active"><span>{$aLang.user_rating}</span></div>
				</th>
			</tr>
		</thead>
	{/if}

	<tbody>
		{if $aUsersList}
			{foreach from=$aUsersList item=oUser}
				{assign var="oSession" value=$oUser->getSession()}
				{assign var="oUserNote" value=$oUser->getUserNote()}
				<tr>
					<td class="cell-name">
						<a href="{$oUser->getUserWebPath()}"><img src="{$oUser->getProfileAvatarPath(48)}"  class="avatar" /></a>
						<div class="name {if !$oUser->getProfileName()}no-realname{/if}">
							<p class="username word-wrap"><a href="{$oUser->getUserWebPath()}" data-user_id="{$oUser->getId()}">{$oUser->getLogin()}</a></p>
							{if $oUser->getProfileName()}<p class="realname">{$oUser->getProfileName()}</p>{/if}
						</div>
					</td>
					<td>
						{if $oUserCurrent}
							{if $oUserNote}
								<button type="button" class="button button-action button-action-note" title="{$oUserNote->getText()|escape:'html'}"><i class="icon-synio-comments-green"></i></button>
							{/if}
							<a href="{router page='talk'}add/?talk_users={$oUser->getLogin()}"><button type="submit"  class="button button-action button-action-send-message" title="{$aLang.user_write_prvmsg}"><i class="icon-synio-send-message"></i></button></a>
						{/if}
					</td>
					<td class="cell-skill">{$oUser->getSkill()}</td>
					<td class="cell-rating {if $oUser->getRating() < 0}negative{/if}"><strong>{$oUser->getRating()}</strong></td>
				</tr>
			{/foreach}
		{else}
			<tr>
				<td colspan="4">
					{if $sUserListEmpty}
						{$sUserListEmpty}
					{else}
						{$aLang.user_empty}
					{/if}
				</td>
			</tr>
		{/if}
	</tbody>
</table>


{include file='paging.tpl' aPaging=$aPaging}