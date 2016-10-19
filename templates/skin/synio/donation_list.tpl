<ul class="donation-list">
    {foreach from=$aDonaters item=oDonater}
        <li>
            <a href="{$oDonater.url}">
                {if $oDonater.avatar_url}
                    <img src="{$oDonater.avatar_url}" class="avatar">
                {/if}
                <span class="text">{$oDonater.login}</span>
            </a>
        </li>
    {/foreach}
</ul>