{foreach from=$aBanners item=oBanner}
    <section class="block block-type-banner">
        <a href="{$oBanner.dest_url}" target="_blank" rel="noopener noreferrer">
            <img src="{$oBanner.img_url}" title="{$oBanner.title}">
        </a>
    </section>
{/foreach}
