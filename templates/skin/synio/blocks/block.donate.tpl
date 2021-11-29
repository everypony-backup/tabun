<div class="donate">
    <a target="_blank" rel="noopener noreferrer" title="На шерстяные носочки для принцессы Луны." href="//everypony.ru/ehelp/">
        <img title="На шерстяные носочки для принцессы Луны."  src="//files.everypony.ru/misc/donate.svg">
    </a>
</div>

<section class="block block-type-donations">
    <header class="block-header sep"><h3>Пожертвования</h3></header>
    <div align="center"><img id="money_svg1" src="https://everypony.ru/api/money.svg" style="margin: 5px;width: 100%; height: auto;" title="Сколько собрано на работу сервера в следующем месяце"></div>
    <div align="center"><img id="money_svg2" src="https://everypony.ru/api/box.svg" style="margin: 5px;width: 100%; height: auto;" title="Сколько накоплено рублей в копилке на будущие расходы"></div>
    <script>document.getElementById('money_svg1').src = document.getElementById('money_svg1').src + '?' + (new Date()).getTime();</script>
    <script>document.getElementById('money_svg2').src = document.getElementById('money_svg2').src + '?' + (new Date()).getTime();</script>
    {hook run='donations'}
</section>
